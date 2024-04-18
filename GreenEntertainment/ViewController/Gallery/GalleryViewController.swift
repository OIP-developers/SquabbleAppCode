//
//  GalleryViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 11/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import UIMultiPicker

class GalleryViewController: UIViewController, AVAssetDownloadDelegate, AVAssetResourceLoaderDelegate  {
    
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        pickerView.isHidden = true
        if selectedChalangesAray.count == 0 {
            AppFunctions.showSnackBar(str: "No Challenge Selected")
            return
        }
    }
    
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var multiPickerView: UIMultiPicker!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var imageArr = ["galler","gallery-1","galler","gallery-1","galler","gallery-1","galler","gallery-1","galler","gallery-1","galler","gallery-1"]
    
    var chalangesArray = [String]()
    var challangeType = ""
    
    var addedToChallange = false
    
    var isFromTabBar = false
    //var gallery = [RewardsModel]()
    var gallery = [VideosModel]()
    var chalanges = [ChallengesModel]()
    var selectedChalangesAray = [Int]()
    var selectedChalangesArayIds = [String]()
    var galleryCompletion: ((Bool, HomeModel) -> Void)? = nil
    var isFromParticipate = false
    var challengeObj = HomeModel()
    var isFromHome = false
    var downloadTask = URLSessionDownloadTask()
    var mediaUrl = ""
    var selectedIndex = 0
    var videoOutputURL: URL {
           
           return URL(fileURLWithPath: NSHomeDirectory() + "/Documents/FinalVideo\(Date().timeIntervalSince1970).mp4")
       }
    
    var configuration: URLSessionConfiguration?
    var downloadSession: AVAssetDownloadURLSession?
    var downloadIdentifier = "\(Bundle.main.bundleIdentifier!).background"

    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        //getGalleryList()
        getUserVideoList()
        //getChalngesList()
        //setupMultiPickerView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if addedToChallange {
            if let tabVC : TabbarViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.children[0] as? TabbarViewController {
                if let chlVc = tabVC.selectedViewController as? ChallengesFeedViewController {
                    chlVc.getHomeVideosList()
                }
            }
        }
    }

    
    //MARK:- Target Method
    @objc func openVideoAction(){
        if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self) {
            vc.isfromPost = true
            vc.videoType = .gallery
            vc.videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }

    //MARK: MultiPicker Func
    
    func setupMultiPickerView() {
        multiPickerView.options = chalangesArray
        
        multiPickerView.addTarget(self, action: #selector(selected(_:)), for: .valueChanged)
        
        multiPickerView.color = .gray
        multiPickerView.tintColor = .white
        multiPickerView.font = .systemFont(ofSize: 18, weight: .semibold)
        
        multiPickerView.highlight(0, animated: false)
    }
    
    @objc func selected(_ sender: UIMultiPicker) {
        
        Logs.show(message: "Selected Index: \(sender.selectedIndexes)")
        
        selectedChalangesAray = sender.selectedIndexes
        Logs.show(message: "Selected CHALLENGES: \(selectedChalangesAray)")
        
    }
    
    
    func getUserVideoList() {
        Logs.show(message: "Saved Vids :::: ")
        
        APIService
            .singelton
            .getMyVideos()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.count)")
                            Logs.show(message: "Saved Vids : \(val)")
                            self.gallery = val
                            self.collectionView.reloadData()
                            //self.navigateToVideoPlayerVC()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "No Videos available")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
        .disposed(by: dispose_Bag)
        
    }
    
    func getChalngesList() {
        Logs.show(message: "Saved Vids :::: ")
        
        APIService
            .singelton
            .getChalenges()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.count)")
                            self.chalanges = val
                            self.chalangesArray = val.filter({ $0.type == self.challangeType }).compactMap({ "\($0.name ?? "")"  })
                            self.setupMultiPickerView()
                            self.collectionView.reloadData()
                        } else {
                            AppFunctions.showSnackBar(str: "No Challenges available")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
        
    }
    
    func participateChllenge(vidId: String) {
        
        //ProgressHud.showActivityLoader()
        
        //for selectedIndexOfCHArray in selectedChalangesAray {
            selectedChalangesArayIds.append(AppFunctions.getChalID())
        //}
        
        let pram : [String : Any] = ["challenges": selectedChalangesArayIds]
        
        Logs.show(message: "SKILLS PRAM: \(pram) , \(vidId)")
        
        APIService
            .singelton
            .participateInChallenge(Pram: pram, vidId: vidId)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            AppFunctions.showSnackBar(str: "Video Added in challenge...")
                            self.addedToChallange = true
                            self.navigationController?.popViewController(animated: true)
                            ProgressHud.hideActivityLoader()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "Error in Subscriptions")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                        ProgressHud.hideActivityLoader()
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
}

extension GalleryViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        let obj = gallery[indexPath.row]
        if let url = URL(string: obj.thumbnail_url ?? "") {
            cell.galleryImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.collectionView.frame.width /  2 - 5, height: self.collectionView.frame.width /  2 + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            //ProgressHud.showActivityLoader()
            //self.selectedIndex = indexPath.row
        
        participateChllenge(vidId: gallery[indexPath.row].id)
            //createMultiPickerView()
            //dismissMultiPickerView()
        /*pickerView.isHidden = false
        selectedChalangesAray.removeAll()
        selectedChalangesArayIds.removeAll()
        multiPickerView.selectedIndexes = []
        multiPickerView.tag = indexPath.row*/
            //self.downloadFile(urlString: self.gallery[indexPath.row].mp4_video_path!)
    }
}

extension GalleryViewController {
    func getGalleryList(){
        WebServices.getGalleryList { (response) in
            if let arr = response?.array {
                //self.gallery = arr
                self.collectionView.setEmptyText(status: self.gallery.count == 0)
                self.collectionView.reloadData()
            }
        }
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 2, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func addBlurEffect(toVideo asset:AVURLAsset, completion: @escaping (_ error: Error?, _ url:URL?) -> Swift.Void) {
           
           let filter = CIFilter(name: "CIGaussianBlur")
           let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
               // Clamp to avoid blurring transparent pixels at the image edges
               let source: CIImage? = request.sourceImage.clampedToExtent()
               filter?.setValue(source, forKey: kCIInputImageKey)
               
               filter?.setValue(10.0, forKey: kCIInputRadiusKey)
               
               // Crop the blurred output to the bounds of the original image
               let output: CIImage? = filter?.outputImage?.cropped(to: request.sourceImage.extent)
               
               // Provide the filter output to the composition
               if let anOutput = output {
                   request.finish(with: anOutput, context: nil)
               }
           })
           
           //let url = URL(fileURLWithPath: "/Users/enacteservices/Desktop/final_video.mov")
           let url = self.videoOutputURL
           // Remove any prevouis videos at that path
           try? FileManager.default.removeItem(at: url)
           
           let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
           
           // assign all instruction for the video processing (in this case the transformation for cropping the video
           exporter?.videoComposition = composition
           exporter?.outputFileType = .mp4
           exporter?.outputURL = url
           exporter?.exportAsynchronously(completionHandler: {
               if let anError = exporter?.error {
                   completion(anError, nil)
               }
               else if exporter?.status == AVAssetExportSession.Status.completed {
                   completion(nil, url)
               }
           })
       }
}


extension GalleryViewController: URLSessionDownloadDelegate {
    func downloadFile(urlString: String) {
            let configuration = URLSessionConfiguration.default
            let operationQueue = OperationQueue()
            let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
            guard let url = URL(string: urlString) else { return }
            let downloadTask = urlSession.downloadTask(with: url)
            self.downloadTask =  downloadTask
            downloadTask.resume()
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            print("finish downloading")

            let fileManager = FileManager.default
            var url: URL?
            do {
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent("project_file.mp4")
                let data = try Data(contentsOf: location)
                try? data.write(to: fileURL)
                url = fileURL
            } catch {
                print(error)
            }

            if let url = url {
                ProgressHud.hideActivityLoader()
                DispatchQueue.main.sync {
                    self.mediaUrl = "\(url)"
                if isFromParticipate || isFromTabBar{
                    if let vc = UIStoryboard.challenge.get(VideoFilterViewController.self){
                        vc.videoURL = url
                        let cell = collectionView.cellForItem(at: IndexPath.init(item: selectedIndex, section: 0)) as! GalleryCollectionViewCell
                        vc.thumbnailImage = cell.galleryImageView.image!  //
                        vc.challengeId = challengeObj.challenge_id
                        vc.homeObj = challengeObj
                        //vc.videoID = Int(self.gallery[self.selectedIndex].video_id ?? "0")
                        //vc.videoObj = self.gallery[self.selectedIndex]
                        vc.videoType = .gallery
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }else {
                    let obj = gallery[self.selectedIndex]
                    if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self) {
                        vc.isfromPost = true
                        vc.videoType = .gallery
                        vc.videoURL = URL(string: obj.video_url ?? "")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    }
                }
            }
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            let percentage = Double(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)) * 100
        }
        
}


extension GalleryViewController {
    
    func setupAssetDownload(videoUrl: String) {
        // Create new background session configuration.
        configuration = URLSessionConfiguration.background(withIdentifier: downloadIdentifier)

        // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
        downloadSession = AVAssetDownloadURLSession(configuration: configuration!,
                                                    assetDownloadDelegate: self,
                                                    delegateQueue: OperationQueue.main)

        if let url = URL(string: videoUrl){
            let asset = AVURLAsset(url: url)

            // Create new AVAssetDownloadTask for the desired asset
            let downloadTask = downloadSession?.makeAssetDownloadTask(asset: asset,
                                                                     assetTitle: "Some Title",
                                                                     assetArtworkData: nil,
                                                                     options: nil)
            // Start task and begin download
            downloadTask?.resume()
        }
    }//end method

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        // Do not move the asset from the download location
        
        print("Path:-\(location.relativePath)")
        
        let baseUrl = URL(fileURLWithPath: NSHomeDirectory()) //app's home directory
        let assetUrl = baseUrl.appendingPathComponent(location.relativePath)
        print("AssetUrl:- \(assetUrl)")
        
        if let vc = UIStoryboard.challenge.get(VideoFilterViewController.self){
            vc.videoURL = assetUrl
            let cell = collectionView.cellForItem(at: IndexPath.init(item: selectedIndex, section: 0)) as! GalleryCollectionViewCell
            vc.thumbnailImage = cell.galleryImageView.image!  //  self.getThumbnailImage(forUrl: url)!
            vc.challengeId = challengeObj.challenge_id
            vc.homeObj = challengeObj
            //vc.videoID = Int(self.gallery[self.selectedIndex].video_id ?? "0")
            //vc.videoObj = self.gallery[self.selectedIndex]
            vc.videoType = .gallery
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentageComplete = 0.0
          for value in loadedTimeRanges {
            print("value:-\(value.timeRangeValue.duration.seconds)")
              let loadedTimeRange = value.timeRangeValue
              percentageComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
          }
            percentageComplete *= 100

    }
    
}
