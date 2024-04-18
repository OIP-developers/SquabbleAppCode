//
//  VideoViewController.swift
//  VideoUI
//
//  Created by PT.Koanba on 10/09/22.
//

import UIKit
import Video
import RxSwift
import FirebaseFirestore
import FirebaseAuth


public protocol VideoViewControllerDelegate {
    func didRequestVideoRefresh(isOnceLoaded: Bool)
}

public final class VideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, VideoLoadingView, VideoErrorView {
    @IBOutlet private(set) public var errorView: UILabel!
    @IBOutlet private(set) public var collectionView: UICollectionView!
    
    @IBOutlet weak var floaterView: Floater!
    
    @IBAction func backBtnPressed(_ sender: Any) {

        if fromVC == "Feed" {
            if goneToVideo {
                goneToUser = false
                goneToVideo = false
                userToGo = ""
                videoToGo = ""
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TabbarViewController")
                navigationController?.pushViewController(vc, animated: true)
            }
        } else if fromVC == "Profile" {
            navigationController?.popViewController(animated: true)
        }
    }
    
    public lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        return refresh
    }()
    
    public var fromVC = ""
    public var isViewLoadedOnce = false
    public var ip = IndexPath()
    public var videoList = [VideosModel]()
    let dispose_Bag = DisposeBag()

    private var loadingControllers = [IndexPath: VideoCellController]()
    private var collectionModel = [VideoCellController]() {
        didSet { self.collectionView?.reloadData() }
    }

    public var delegate: VideoViewControllerDelegate?

    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        refreshCollectionView()
        self.floaterView.isHidden = true
        
        _ = AppFunctions.generalPublisher.subscribe(onNext: {[weak self] val in
            
            Logs.show(message: "VLAUE : \(val)")
            switch val {
                    
                case "home":
                    let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
                    
                    let vc : TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
                    vc.selectedIndex = 0
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                case "vote":
                    if Auth.auth().currentUser != nil {
                        self?.likeVideo(vidId: self?.videoList[AppFunctions.getRow()].id ?? "", ip: IndexPath(row: AppFunctions.getRow(), section: 0))
                    } else {
                        self?.showAlert()
                    }
                    
                case "profile":
                    
                    let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
                    let vc : TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
                    vc.selectedIndex = 4
                    goneToUser = true
                    userToGo = (self?.videoList[AppFunctions.getRow()].userId)!
                    self?.navigationController?.pushViewController(vc, animated: true)
                    /*if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                        vc.user_id = (self?.videoList[AppFunctions.getRow()].userId)!
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }*/
                    print("")
                case "mute":
                    print("")
                case "share":
                    self?.showActionSheet()
                    print("")
                case "message":
                    if Auth.auth().currentUser != nil {
                        self?.AddMessageUserList()
                    } else {
                        self?.showAlert()
                    }
                    
                    print("")
                case "gift":
                    if Auth.auth().currentUser != nil {
                        self?.sendGift(userId: self?.videoList[AppFunctions.getRow()].userId ?? "")
                    } else {
                        self?.showAlert()
                    }
                    
                    print("")
                case "follow":
                    if Auth.auth().currentUser != nil {
                        self?.followUnfollowUser(userId: self?.videoList[AppFunctions.getRow()].userId ?? "")
                    } else {
                        self?.showAlert()
                    }
                    
                    print("")
                case "general":
                    
                    self?.errorView?.isHidden = true
                    self?.stopPlayingVideo()
                    if !self!.isViewLoadedOnce {
                        self?.isViewLoadedOnce = true
                        self?.delegate?.didRequestVideoRefresh(isOnceLoaded: false)
                    } else {
                        self?.delegate?.didRequestVideoRefresh(isOnceLoaded: true)
                    }
                    
                    print("")
                case "following":
                    
                    self?.errorView?.isHidden = true
                    self?.stopPlayingVideo()
                    if !self!.isViewLoadedOnce {
                        self?.isViewLoadedOnce = true
                        self?.delegate?.didRequestVideoRefresh(isOnceLoaded: false)
                    } else {
                        self?.delegate?.didRequestVideoRefresh(isOnceLoaded: true)
                    }
                    
                    print("")
                case "trend":
                    
                    self?.errorView?.isHidden = true
                    self?.stopPlayingVideo()
                    if !self!.isViewLoadedOnce {
                        self?.isViewLoadedOnce = true
                        self?.delegate?.didRequestVideoRefresh(isOnceLoaded: false)
                    } else {
                        self?.delegate?.didRequestVideoRefresh(isOnceLoaded: true)
                    }
                    
                    print("")
                default:
                    print("")
            }

            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
        print("FROM VC ::: \(fromVC)")
    }
    
    func showAlert() {
        // create the alert
        let alert = UIAlertController(title: "Alert", message: "You are not logged in Squabble App, want to login?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: { action in
            
            // do something like...
            let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
            let vc : TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
            vc.selectedIndex = 4
            self.navigationController?.pushViewController(vc, animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
            
            // do something like...
            alert.dismiss(animated: true)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.contentInsetAdjustmentBehavior = .never /// to fill up safeare space
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlayingVideo()
    }
    
    private func startEndAnimation() {
        floaterView.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.floaterView.stopAnimation()
            self.floaterView.isHidden = true
        })
    }
    
    
    private func setupCollectionView() {
        collectionView?.refreshControl = refreshControl
        refreshControl.beginRefreshing()
    }

    @objc private func refreshCollectionView() {
        errorView?.isHidden = true
        stopPlayingVideo()
        if !isViewLoadedOnce {
            isViewLoadedOnce = true
            delegate?.didRequestVideoRefresh(isOnceLoaded: false)
        } else {
            delegate?.didRequestVideoRefresh(isOnceLoaded: true)
        }
        
    }
    
    private func stopPlayingVideo() {
        loadingControllers.forEach { key, cell in
            cell.cancelLoad()
        }
    }

    public func display(_ cellControllers: [VideoCellController]) {
        loadingControllers = [:]
        collectionModel = cellControllers
    }

    public func display(_ viewModel: VideoLoadingViewModel) {
        refreshControl.update(isRefreshing: viewModel.isLoading)
    }

    public func display(_ viewModel: VideoErrorViewModel) {
        errorView?.isHidden = false
        errorView?.text = viewModel.message
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionModel.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt \(indexPath)")
        
        let cellController = cellController(forRowAt: indexPath)
        let cell = cellController.view(in: collectionView, indexPath: indexPath, fromVC: fromVC, video: videoList[indexPath.row]) as! VideoCell
        cell.cellController = cellController
        cell.delegate = self
        return cell
        
        return cell
        //return cellController(forRowAt: indexPath).view(in: collectionView, indexPath: indexPath, fromVC: fromVC, video: videoList[indexPath.row])
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("willDisplayCell \(indexPath)")
        
        cellController(forRowAt: indexPath).willDisplay(cell, in: collectionView, indexPath: indexPath, video: videoList[indexPath.row])
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplayingCell \(indexPath)")
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)

    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> VideoCellController {
        if ip.row != -1 {
            let newIp = ip
            ip = IndexPath(row: -1, section: -1)
            let controller = collectionModel[newIp.row]
            loadingControllers[newIp] = controller
            collectionView.scrollToItem(at: newIp, at: .top, animated: false)
            return controller
        } else {
            let controller = collectionModel[indexPath.row]
            loadingControllers[indexPath] = controller
            return controller
        }
        
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        getStopedScrollCellIndex(scrollView)
    }
    
    public func getStopedScrollCellIndex(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        let cell = cellController(forRowAt: indexPath)
        cell.play()
    }
    
    public override func didReceiveMemoryWarning() {
        if loadingControllers.count > 20 {
            for i  in  0...10 {
                let removeIndex = IndexPath(item: i, section: 0)
                if let idx = loadingControllers.index(forKey: removeIndex){
                    loadingControllers.remove(at: idx)
                }

            }
        }
    }
    
    // MARK: Helper FUNCTIONS
    
    
    func showActionSheet() {
        
        let optionMenu =  UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        optionMenu.view.tintColor = .red
        let appGalleryAction = UIAlertAction(title: "Share Internally", style: .default, handler:
                                                {
            
            (alert: UIAlertAction!) -> Void in
            
            self.showShareList()
            
        })
        
        let libraryAction = UIAlertAction(title: "Share Externally", style: .default, handler:
                                            {
            (alert: UIAlertAction!) -> Void in
            self.shareApp(text: "Hey,\n\n\(self.videoList[AppFunctions.getRow()].name ?? "") invites you to join Squabble.\n\nAndroid app link:\nhttps://play.google.com/store/apps/details?id=com.green.squabble\n\niOS Link:\nhttps://apps.apple.com/us/app/squabble-win/id1561097344", image: UIImage(named: "ic_squab")!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(appGalleryAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    func shareApp(text: String, image: UIImage) {
        let shareAll = [text , image] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
        ]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: API FUNCTIONS
    
    
    func likeVideo(vidId: String, ip : IndexPath) {
        APIService
            .singelton
            .likeVideo(videoId: vidId)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val == "like" {
                            self.floaterView.isHidden = false
                            self.startEndAnimation()
                            Logs.show(message: "\(val)")
                            AppFunctions.saveLike(val: [vidId : "like"])
                            AppFunctions.generalPublisher.onNext("LIKED_VIDEO")
                        } else {
                            Logs.show(message: "Val 0")
                            AppFunctions.saveLike(val: [vidId : "unlike"])
                            AppFunctions.generalPublisher.onNext("UNLIKED_VIDEO")
                        }
                        
//                        DispatchQueue.main.async {
//                            self.collectionView.reloadItems(at: [ip])
//                        }
                        
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func followUnfollowUser(userId: String) {
        APIService
            .singelton
            .followUnFollowUser(userId: userId)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        //if val {
                            
                            if val.contains("follow") {
                                self.floaterView.isHidden = false
                                self.startEndAnimation()
                                Logs.show(message: "\(val)")
                                //AppFunctions.saveLike(val: [vidId : "like"])
                                AppFunctions.generalPublisher.onNext("FOLLOWED")
                            } else {
                                Logs.show(message: "Val 0")
                                //AppFunctions.saveLike(val: [vidId : "unlike"])
                                AppFunctions.generalPublisher.onNext("UNFOLLOWED")
                            }
                            Logs.show(message: "OBJ \(val)")
                            //AppFunctions.showSnackBar(str: "User added to followers")
                        //}
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func sendGift(userId: String) {
        
        let pram : [String : Any] = ["receiverId": userId,
                                     "transfer" : 2]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .sendGift(Pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            Logs.show(message: "OBJ \(val)")
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }

    // MARK: Firebase FUNCTIONS
    
    func AddMessageUserList() {
        
        var user1 = [String:Any]()
        if Auth.auth().currentUser != nil {
            user1["sender_id"] = AppFunctions.getUserID()
            user1["receiver_id"] = videoList[AppFunctions.getRow()].user.id
            user1["name"] = videoList[AppFunctions.getRow()].user.first_name
            user1["blockStatus"] = false
            
            let userIds = [videoList[AppFunctions.getRow()].user.id, AppFunctions.getUserID()].compactMap { $0 }
            let sortedIds = userIds.sorted()
            user1["chatChannelId"] = sortedIds.joined(separator: " - ")
            
            user1["profilePic"] = videoList[AppFunctions.getRow()].user.profile_picture == nil ? "https://firebasestorage.googleapis.com:443/v0/b/squabble-42140.appspot.com/o/Images_Folder%2FprofImage_1664877616.jpg?alt=media&token=06573605-861a-4d75-a304-313d833a9b8f" : videoList[AppFunctions.getRow()].user.profile_picture
            
            //db.collection("ChatUsers").document(videoList[AppFunctions.getRow()].user.id).setData(user1)
            
            let storyboard = UIStoryboard(name: "Message", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                let transition = CATransition()
                transition.duration = 0.5
                transition.subtype = CATransitionSubtype.fromRight
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
                transition.type = CATransitionType.fade
                self.navigationController?.view.layer.add(transition, forKey: nil)
                vc.user1 = user1
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func showShareList() {
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ShareUserListVC") as? ShareUserListVC {
            
            vc.modalPresentationStyle = .automatic
            vc.videoUrl = self.videoList[AppFunctions.getRow()].id ?? ""
            self.present(vc, animated: true)
        }
    }
    
}

extension VideoViewController: VideoCellDelegate {
    func didTapButton(in cell: VideoCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        AppFunctions.saveRow(row: indexPath.row)
        Logs.show(message: "Button was tapped in cell at index path: \(indexPath)")
    }
}
