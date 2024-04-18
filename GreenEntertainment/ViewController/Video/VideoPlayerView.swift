//
//  VideoPlayerView.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on Tuesday27/09/2022.
//  Copyright © 2022 Quytech. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    // MARK: - Variables
    var videoURL: URL?
    var originalURL: URL?
    var asset: AVURLAsset?
    var playerItem: AVPlayerItem?
    var avPlayerLayer: AVPlayerLayer!
    var playerLooper: AVPlayerLooper! // should be defined in class
    var queuePlayer: AVQueuePlayer?
    var observer: NSKeyValueObservation?
    
    var playbackBufferEmptyObserver: NSKeyValueObservation?
    var playbackBufferFullObserver: NSKeyValueObservation?
    var playbackLikelyToKeepUpObserver: NSKeyValueObservation?

    
    var playerTryCount = -1 // this should get set to 0 when the AVPlayer starts playing
    let playerTryCountMaxLimit = 20
    
    private var session: URLSession?
    private var loadingRequests = [AVAssetResourceLoadingRequest]()
    private var task: URLSessionDataTask?
    private var infoResponse: URLResponse?
    private var cancelLoadingQueue: DispatchQueue?
    private var videoData: Data?
    private var fileExtension: String?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avPlayerLayer.frame = self.layer.bounds
    }
    
    func setupView(){
        let operationQueue = OperationQueue()
        operationQueue.name = "com.VideoPlayer.URLSeesion"
        operationQueue.maxConcurrentOperationCount = 1
        session = URLSession.init(configuration: .default, delegate: self, delegateQueue: operationQueue)
        cancelLoadingQueue = DispatchQueue.init(label: "com.cancelLoadingQueue")
        videoData = Data()
        avPlayerLayer = AVPlayerLayer(player: queuePlayer)
        //avPlayerLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(self.avPlayerLayer)
    }
    
    func configure(url: URL?, fileExtension: String?){
        // If Height is larger than width, change the aspect ratio of the video
        avPlayerLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(self.avPlayerLayer)
        
        //var newUrl : URL?
        
//        let avAsset = AVURLAsset(url: url!, options: nil)
//        avAsset.exportVideo(presetName: AVAssetExportPresetHighestQuality, outputFileType: AVFileType.mp4, fileExtension: "mp4") { (mp4Url) in
//            Logs.show(message: "Mp4 converted url : \(String(describing: mp4Url))")
//            newUrl = mp4Url
//        }
        
        
        guard let url = url else {
            print("URL Error from Tableview Cell")
            return
        }
        self.fileExtension = fileExtension
        VideoCacheManager.shared.queryURLFromCache(key: url.absoluteString, fileExtension: fileExtension, completion: {[weak self] (data) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let path = data as? String {
                    self.videoURL = URL(fileURLWithPath: path)
                } else {
                    // Adding Redirect URL(customized prefix schema) to trigger AVAssetResourceLoaderDelegate
                    guard let redirectUrl = url.convertToRedirectURL(scheme: "streaming") else {
                        print("\(url)\nCould not convert the url to a redirect url.")
                        return
                    }
                    self.videoURL = redirectUrl
                }
                self.originalURL = url
                
                
                //self.asset = AVURLAsset(url: self.videoURL!)
                //self.asset!.resourceLoader.setDelegate(self, queue: .main)
                //self.asset!.resourceLoader.setDelegate(self, queue:  DispatchQueue.global(qos: .userInitiated))

                let mimeType = "video/mp4"//; codecs=\"avc1.42E01E, mp4a.40.2\""
                
                // create asset
                self.asset = AVURLAsset(url: self.videoURL!, options: [
                    "AVURLAssetOutOfBandMIMETypeKey": mimeType
                ])
                self.asset!.resourceLoader.setDelegate(self, queue: .main)

                //self.asset!.resourceLoader.setDelegate(self, queue:  DispatchQueue.global(qos: .userInitiated))


                self.playerItem = AVPlayerItem(asset: self.asset!)
                self.addObserverToPlayerItem()
                
                //self.queuePlayer?.automaticallyWaitsToMinimizeStalling = true
                //self.queuePlayer?.playImmediately(atRate: 1.0)
                
                if let queuePlayer = self.queuePlayer {
                    queuePlayer.replaceCurrentItem(with: self.playerItem)
                } else {
                    self.queuePlayer = AVQueuePlayer(playerItem: self.playerItem)
                }
                
                self.playerLooper = AVPlayerLooper(player: self.queuePlayer!, templateItem: self.queuePlayer!.currentItem!)
                self.avPlayerLayer.player = self.queuePlayer
                
            }
        })
    }
    
    /// Clear all remote or local request
    func cancelAllLoadingRequest(){
        removeObserver()
        
        videoURL = nil
        originalURL = nil
        asset = nil
        playerItem = nil
        avPlayerLayer.player = nil
        playerLooper = nil
        
        cancelLoadingQueue?.async { [weak self] in
            self?.session?.invalidateAndCancel()
            self?.session = nil
            
            self?.asset?.cancelLoading()
            self?.task?.cancel()
            self?.task = nil
            self?.videoData = nil
            
            self?.loadingRequests.forEach { $0.finishLoading() }
            self?.loadingRequests.removeAll()
        }
        
    }
    
    
    func replay(){
        self.queuePlayer?.seek(to: .zero)
        play()
    }
    
    func play() {
        self.queuePlayer?.play()
    }
    
    func pause(){
        self.queuePlayer?.pause()
    }

}

// MARK: - KVO
extension VideoPlayerView {
    func removeObserver() {
        if let observer = observer {
            observer.invalidate()
        }
//        if let playbackBufferEmptyObserver = playbackBufferEmptyObserver {
//            playbackBufferEmptyObserver.invalidate()
//        }
//        if let playbackBufferFullObserver = playbackBufferFullObserver {
//            playbackBufferFullObserver.invalidate()
//        }
//        if let playbackLikelyToKeepUpObserver = playbackLikelyToKeepUpObserver {
//            playbackLikelyToKeepUpObserver.invalidate()
//        }
        
    }
    
    fileprivate func addObserverToPlayerItem() {
        // Register as an observer of the player item's status property
        
        
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemPlaybackStalled(_:)),
        //                                               name: NSNotification.Name.AVPlayerItemPlaybackStalled,
        //                                               object: playerItem)
        //
        self.observer = self.playerItem!.observe(\.status, options: [.initial, .new], changeHandler: { item, _ in
            let status = item.status
            // Switch over the status
            switch status {
                case .readyToPlay:
                    // Player item is ready to play.
                    print("Status: readyToPlay")
                    //self.play()
                    Constants.generalPublisher.onNext("playVid")
                case .failed:
                    // Player item failed. See error.
                    print("Status: failed Error: \(String(describing: item.error))" )
                case .unknown:
                    // Player item is not yet ready.bn m
                    print("Status: unknown")
                @unknown default:
                    fatalError("Status is not yet ready to present")
            }
        })
    }
//        playbackBufferEmptyObserver = self.playerItem?.observe(\.isPlaybackBufferEmpty, options: [.new, .initial ], changeHandler: { [weak self] (player, bufferEmpty) in
//
//            if let self = self {
//                DispatchQueue.main.async {
//                    if bufferEmpty.newValue == true {
//                        // handle showing loading, player not playing
//                        Logs.show(message: "handle showing loading, player not playing")
//                        ProgressHud.showActivityLoader()
//                    }
//                }
//            }
//        })
//
//        playbackBufferFullObserver = self.playerItem?.observe(\.isPlaybackBufferFull, options: [.new, .initial], changeHandler: {[weak self] (player, bufferFull) in
//            if let self = self {
//                DispatchQueue.main.async {
//                    if bufferFull.newValue == true {
//                        //handle when player buffer is full (e.g. hide loading) start player
//                        Logs.show(message: "handle when player buffer is full (e.g. hide loading) start player")
//                        ProgressHud.hideActivityLoader()
//
//                    }
//                }
//            }
//        })
//
//        playbackLikelyToKeepUpObserver = self.playerItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.new, .initial], changeHandler: { [weak self] (player, _) in
//            if let self = self {
//                if ((self.playerItem?.status ?? AVPlayerItem.Status.unknown)! == .readyToPlay) {
//                    //  handle that player is  ready to play (e.g. hide loading indicator, start player)
//                    Logs.show(message: "handle that player is  ready to play (e.g. hide loading indicator, start player)")
//                    ProgressHud.hideActivityLoader()
//
//                } else {
//                    Logs.show(message: "player is not ready to play yet")
//                    ProgressHud.showActivityLoader()
//
//                    //  player is not ready to play yet
//                }
//            }
//        })
//
//    }
//
//
//    @objc func playerItemPlaybackStalled(_ notification: Notification) {
//        // The system may post this notification on a thread other than the one used to registered the observer: https://developer.apple.com/documentation/foundation/nsnotification/name/1387661-avplayeritemplaybackstalled
//
//        guard let playerItem = notification.object as? AVPlayerItem else { return }
//
//        // playerItem.isPlaybackLikelyToKeepUp == false && if the player's current time is greater than zero && the player's current time is not equal to the player's duration
//        if (!playerItem.isPlaybackLikelyToKeepUp) && (CMTimeCompare(playerItem.currentTime(), .zero) == 1) && (CMTimeCompare(playerItem.currentTime(), playerItem.duration) != 0) {
//
//            DispatchQueue.main.async { [weak self] in
//                self?.playerIsHanging()
//                Logs.show(message: "playerIsHanging")
//
//            }
//        }
//    }
//
//    func playerIsHanging() {
//
//        if playerTryCount <= playerTryCountMaxLimit {
//
//            playerTryCount += 1
//
//            // show spinner
//
//            checkPlayerTryCount()
//            print("111.-----> PROBLEM")
//
//        } else {
//            // show spinner, show alert, or possibly use player?.replaceCurrentItem(with: playerItem) to start over ***BE SURE TO RESET playerTryCount = 0 ***
//            print("1.-----> PROBLEM")
//        }
//    }
//
//    func checkPlayerTryCount() {
//
//        //guard let player = player, let playerItem = player.currentItem else { return }
//        Logs.show(message: "checkPlayerTryCount")
//
//        // if the player's current time is equal to the player's duration
//        if CMTimeCompare(playerItem!.currentTime(), playerItem!.duration) == 0 {
//
//            // show spinner or better yet remove spinner and show a replayButton or auto rewind to the beginning ***BE SURE TO RESET playerTryCount = 0 ***
//
//        } else if playerTryCount > playerTryCountMaxLimit {
//
//            // show spinner, show alert, or possibly use player?.replaceCurrentItem(with: playerItem) to start over ***BE SURE TO RESET playerTryCount = 0 ***
//            print("2.-----> PROBLEM")
//
//        } else if playerTryCount == 0 {
//
//            // *** in his answer he has nothing but a return statement here but when it would hit this condition nothing would happen. I had to add these 2 lines of code for it to continue ***
//            playerTryCount += 1
//            retryCheckPlayerTryCountAgain()
//            return // protects against a race condition
//
//        } else if playerItem!.isPlaybackLikelyToKeepUp {
//
//            // remove spinner and reset playerTryCount to zero
//            playerTryCount = 0
//            queuePlayer?.play()
//
//        } else { // still hanging, not at end
//
//            playerTryCount += 1
//
//            /*
//             create a 0.5-second delay using .asyncAfter to see if buffering catches up
//             then call retryCheckPlayerTryCountAgain() in a manner that attempts to avoid any recursion or threading nightmares
//             */
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                DispatchQueue.main.async { [weak self] in
//
//                    // test playerTryCount again to protect against changes that might have happened during the 0.5 second delay
//                    if self!.playerTryCount > 0 {
//
//                        if self!.playerTryCount <= self!.playerTryCountMaxLimit {
//
//                            self!.retryCheckPlayerTryCountAgain()
//
//                        } else {
//
//                            // show spinner, show alert, or possibly use player?.replaceCurrentItem(with: playerItem) to start over ***BE SURE TO RESET playerTryCount = 0 ***
//                            print("3.-----> PROBLEM")
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func retryCheckPlayerTryCountAgain() {
//        Logs.show(message: "retryCheckPlayerTryCountAgain")
//
//        checkPlayerTryCount()
//    }
}

// MARK: - URL Session Delegate
extension VideoPlayerView: URLSessionTaskDelegate, URLSessionDataDelegate {
    // Get Responses From URL Request
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.infoResponse = response
        self.processLoadingRequest()
        completionHandler(.allow)
    }
    
    // Receive Data From Responses and Download
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.videoData?.append(data)
        self.processLoadingRequest()
    }
    
    // Responses Download Completed
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("AVURLAsset Download Data Error: " + error.localizedDescription)
        } else {
            VideoCacheManager.shared.storeDataToCache(data: self.videoData, key: self.originalURL!.absoluteString, fileExtension: self.fileExtension)
        }
    }
    
    private func processLoadingRequest(){
        var finishedRequests = Set<AVAssetResourceLoadingRequest>()
        self.loadingRequests.forEach {
            var request = $0
            if self.isInfo(request: request), let response = self.infoResponse {
                self.fillInfoRequest(request: &request, response: response)
            }
            if let dataRequest = request.dataRequest, self.checkAndRespond(forRequest: dataRequest) {
                finishedRequests.insert(request)
                request.finishLoading()
            }
        }
        self.loadingRequests = self.loadingRequests.filter { !finishedRequests.contains($0) }
    }
    
    private func fillInfoRequest(request: inout AVAssetResourceLoadingRequest, response: URLResponse) {
        request.contentInformationRequest?.isByteRangeAccessSupported = true
        request.contentInformationRequest?.contentType = response.mimeType
        request.contentInformationRequest?.contentLength = response.expectedContentLength
    }
    
    private func isInfo(request: AVAssetResourceLoadingRequest) -> Bool {
        return request.contentInformationRequest != nil
    }
    
    private func checkAndRespond(forRequest dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
        guard let videoData = videoData else { return false }
        let downloadedData = videoData
        let downloadedDataLength = Int64(downloadedData.count)
        
        let requestRequestedOffset = dataRequest.requestedOffset
        let requestRequestedLength = Int64(dataRequest.requestedLength)
        let requestCurrentOffset = dataRequest.currentOffset
        
        if downloadedDataLength < requestCurrentOffset {
            return false
        }
        
        let downloadedUnreadDataLength = downloadedDataLength - requestCurrentOffset
        let requestUnreadDataLength = requestRequestedOffset + requestRequestedLength - requestCurrentOffset
        let respondDataLength = min(requestUnreadDataLength, downloadedUnreadDataLength)
        
        dataRequest.respond(with: downloadedData.subdata(in: Range(NSMakeRange(Int(requestCurrentOffset), Int(respondDataLength)))!))
        
        let requestEndOffset = requestRequestedOffset + requestRequestedLength
        
        return requestCurrentOffset >= requestEndOffset
        
    }
}

// MARK: - AVAssetResourceLoader Delegate
extension VideoPlayerView: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if task == nil, let url = originalURL {
            let request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
            task = session?.dataTask(with: request)
            task?.resume()
        }
        self.loadingRequests.append(loadingRequest)
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = self.loadingRequests.firstIndex(of: loadingRequest) {
            self.loadingRequests.remove(at: index)
        }
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        didCancel authenticationChallenge:  URLAuthenticationChallenge) {
        /// handle the authentication challenge
        print(authenticationChallenge.error.debugDescription)
    }
    
}
