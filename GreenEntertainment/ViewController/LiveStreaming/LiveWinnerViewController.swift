////
////  LiveWinnerViewController.swift
////  GreenEntertainment
////
////  Created by Prateek Keshari on 30/07/20.
////  Copyright © 2020 Quytech. All rights reserved.
////
//
//import UIKit
//import AgoraRtcKit
//import AgoraRtmKit
//import ReplayKit
//import WebKit
//
//class LiveWinnerViewController: UIViewController, WKScriptMessageHandler {
//  
//    
//    
//    let kAppId = "1cec3a45e11c46d7b9c21e70442599c6"
//    var token =  "0061cec3a45e11c46d7b9c21e70442599c6IACfE4EZUSkzgmhO3dntrqoFH3eky+NVlOn11jOVUdwifraAVfQAAAAAIgBAOwEAr9kjXwQAAQAAAAAAAwAAAAAAAgAAAAAABAAAAAAA"
//    
//    var channelName = "Squabble Live Streaming"
//    var challengeId = ""
//    
//    var encoded_token = ""
//    
//    @IBOutlet weak var remoteVideo: AGEVideoContainer!
//    @IBOutlet weak var crossButton: UIButton!
//    @IBOutlet weak var joinButton: UIButton!
//    @IBOutlet weak var viewsLabel: UILabel!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var bottomView: UIView!
//    @IBOutlet weak var bottomLastView: UIView!
//    @IBOutlet weak var innerView: UIView!
//    
//    @IBOutlet weak var webView: WKWebView!
//    
//    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
//    
//    
//    var webVieww = WKWebView()
//    
//    lazy var list = [Message]()
//    var rtmChannel: AgoraRtmChannel?
//    var rtmKit: AgoraRtmKit?
//    let width = Window_Width
//    let height = Window_Height
//    
//    var mNativeToWebHandler : String = "jsMessageHandler"
//
//    
//    private lazy var agoraKit: AgoraRtcEngineKit = {
//        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: kAppId, delegate: self)
//        engine.setLogFilter(AgoraLogFilter.info.rawValue)
//        engine.setLogFile(FileCenter.logFilePath())
//        return engine
//    }()
//    
//    private var videoSessions = [VideoSession]() {
//        didSet {
//            // update render view layout
//            updateBroadcastersView()
//        }
//    }
//    
//    
//    var isRemoteVideoRender: Bool = true {
//        didSet {
//            
//        }
//    }
//    
//    var isLocalVideoRender: Bool = false {
//        didSet {
//        }
//    }
//    
//    
//    //MARK:- UIViewController Lifecycle Method
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupRTM()
//        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
//        if Window_Height == 667 {
//            tableViewHeightConstraint.constant = Window_Height * 0.23
//        }else if Window_Height == 896 {
//            tableViewHeightConstraint.constant = Window_Height * 0.22
//        }else {
//            tableViewHeightConstraint.constant = Window_Height * 0.24
//        }
//        // Do any additional setup after loading the view.
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        delay(delay: 0.1) {
//            self.getLiveStatus()
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if let clearURL = URL(string: "about:blank") {
//            webVieww.load(URLRequest(url: clearURL))
//        }
//        self.leaveChannel()
//    }
//    
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        if UIDevice.current.orientation.isLandscape {
//            
//            if Window_Height == 896 {
//                self.webVieww.frame = CGRect.init(x: -50, y: 50, width:
//                                                    self.height, height:self.width - 80)
//                self.viewDidLayoutSubviews()
//            }else if Window_Height == 736 {
//                self.webVieww.frame = CGRect.init(x: 0, y: 50, width:
//                                                    self.height, height:self.width - 100)
//                self.viewDidLayoutSubviews()
//            }else if Window_Height == 667 {
//                self.webVieww.frame = CGRect.init(x: 0, y: 50, width:
//                                                    self.height, height:self.width - 85)
//                self.viewDidLayoutSubviews()
//            }
//            
//            self.viewDidLayoutSubviews()
//            
//            
//        } else {
//            webVieww.frame = CGRect.init(x: 0, y: 0, width:
//                                            Window_Width, height:Window_Height)
//            self.viewDidLayoutSubviews()
//        }
//    }
//    
//    
//    
//    func setupWebView(){
//        let webConfiguration = WKWebViewConfiguration()
//        webConfiguration.allowsInlineMediaPlayback = true
//        webConfiguration.requiresUserActionForMediaPlayback = false
//        webConfiguration.mediaPlaybackRequiresUserAction = false
//        
//        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
//        
//        webVieww = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: innerView.frame.width, height: innerView.frame.height), configuration: webConfiguration)
//        
//        let url = URL(string: "https://quytech.net/green-entertainment/client?token=\(encoded_token)")
//        print("URL:-\("https://quytech.net/green-entertainment/client?token=\(encoded_token)")")
//        webVieww.navigationDelegate = self
//        webView.navigationDelegate = self
//        webVieww.uiDelegate = self
//        webVieww.scrollView.isScrollEnabled = false
//        webView.scrollView.isScrollEnabled = false
//        webVieww.load(URLRequest(url: url!))
//        webVieww.configuration.userContentController.add(self, name: mNativeToWebHandler)
//
//        self.innerView.addSubview(webVieww)
//    }
//    
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        print("\(message.name)")
//        print("asd\(message.body)")
//        if message.name == mNativeToWebHandler {
//          print("Aaya")
//        }
//    }
//    
//    // MARK:- Helper Methods
//    func addLocalSession() {
//        let localSession = VideoSession.localSession()
//        localSession.updateInfo(fps: 15)
//        videoSessions.append(localSession)
//        agoraKit.setupLocalVideo(localSession.canvas)
//    }
//    
//    
//    func setupRTM(){
//        rtmKit = AgoraRtmKit.init(appId: "1cec3a45e11c46d7b9c21e70442599c6", delegate: self)
//        rtmKit?.login(byToken: nil, user: "\(AuthManager.shared.loggedInUser?.first_name ?? "\(RAND_MAX)") user", completion: { (error) in
//            print("error::-\(error.rawValue)")
//        })
//        rtmKit?.agoraRtmDelegate = self
//        rtmChannel = rtmKit?.createChannel(withId: "Squabble Live Streaming", delegate: self)
//        
//        delay(delay: 0.4) {
//            self.rtmChannel?.join(completion: { (error) in
//                self.rtmKit?.agoraRtmDelegate = self
//                self.viewsLabel.text = "Views 1"
//                print("error::------\(error.rawValue)")
//            })
//        }
//        
//        rtmChannel?.channelDelegate = self
//        rtmKit?.agoraRtmDelegate = self
//        
//    }
//    
//    
//    func leaveChannel() {
//        // leave channel and end chat
//        agoraKit.leaveChannel(nil)
//        
//        isRemoteVideoRender = false
//        isLocalVideoRender = false
//        agoraKit.stopPreview()
//        //   isStartCalling = false
//        UIApplication.shared.isIdleTimerDisabled = false
//        print("did leave channel")
//        leaveRtmChannel()
//        self.updateLiveStatus(status: false)
//        // self.logVC?.log(type: .info, content: "did leave channel")
//    }
//    
//    //MARK:- Keyboard Methods
//    @objc func keyboardWillShow(sender: NSNotification) {
//        if let userInfo = sender.userInfo {
//            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
//            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
//            if let keyboardHeight = keyboardHeight {
//                viewBottomConstraint.constant = -keyboardHeight + 30
//                UIView.animate(withDuration: duration, animations: { () -> Void in
//                    self.view.layoutIfNeeded()
//                    self.perform(#selector(self.scrollToBottom), with: nil, afterDelay: 0.0)
//                })
//            }
//        }
//        
//        
//    }
//    
//    @objc func keyboardWillHide(sender: NSNotification) {
//        viewBottomConstraint.constant = 0.0
//        UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded()
//        })
//        self.perform(#selector(scrollToBottom), with: nil, afterDelay: 0.2)
//    }
//    
//    //MARK:- Target Method
//    @objc func scrollToBottom() {
//        if self.list.count > 0 {
//            self.tableView.scrollToRow(at: IndexPath.init(row: self.list.count - 1 , section: 0), at:.bottom, animated: false)
//        }
//    }
//    
//    //MARK:- UIButton Action Methods
//    @IBAction func didClickHangUpButton(_ sender: UIButton) {
//        sender.isSelected.toggle()
//        if sender.isSelected {
//            leaveChannel()
//        } else {
//            joinGroup()
//        }
//    }
//    
//    @IBAction func crossButtonButton(_ sender: UIButton) {
//        leaveRtmChannel()
//        updateLiveStatus(status: false)
//        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    @IBAction func didClickMuteButton(_ sender: UIButton) {
//        sender.isSelected.toggle()
//        // mute local audio
//        agoraKit.muteLocalAudioStream(sender.isSelected)
//    }
//    
//    @IBAction func sendButtonAction(_ sender: UIButton){
//        self.view.endEditing(true)
//        if textView.text.trimWhiteSpace.isEmpty {
//            AlertController.alert(message: "Please enter message.")
//        }else {
//            if Reachabilityy.isConnectedToNetwork() {
//                send(message: textView.text.trimWhiteSpace)
//            }else{
//                AlertController.alert(message: "No internet Connection.")
//            }
//        }
//    }
//    
//}
//
//extension LiveWinnerViewController: WKNavigationDelegate,WKUIDelegate {
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
//        
//        switch navigationAction.request.url?.absoluteString {
//        case "https://www.quytech.com/":
//            delay(delay: 2.5) {
//                self.viewsLabel.isHidden = false
//                self.bottomView.isHidden = false
//                self.tableView.isHidden = false
//                self.viewsLabel.isHidden = false
//                self.bottomLastView.isHidden = false
//            }
//            decisionHandler(.allow)
//            break
//        default:
//            decisionHandler(.allow)
//            break
//        }
//    }
//}
//
//
//extension LiveWinnerViewController {
//    
//    func updateBroadcastersView() {
//        // video views layout
//        remoteVideo.reload(level: 0, animated: true)
//    }
//    
//    func loadAgoraKit() {
//        setIdleTimerActive(false)
//        
//        // Step 1, set delegate to inform the app on AgoraRtcEngineKit events
//        agoraKit.delegate = self
//        
//        // Step 2, set live broadcasting mode
//        // for details: https://docs.agora.io/cn/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/setChannelProfile:
//        agoraKit.setChannelProfile(.liveBroadcasting)
//        
//        // set client role
//        agoraKit.setClientRole(.audience)
//        agoraKit.startPreview()
//        
//        
//        // Step 3, Warning: only enable dual stream mode if there will be more than one broadcaster in the channel
//        
//        // Step 4, enable the video module
//        agoraKit.enableVideo()
//        // set video configuration
//        
//        addLocalSession()
//        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x480,
//                                                                             frameRate: .fps7,
//                                                                             bitrate: AgoraVideoBitrateStandard,
//                                                                             orientationMode: .adaptative))
//        
//        
//        self.joinGroup()
//        
//    }
//    
//    
//    
//    func joinGroup() {
//        
//        // Step 5, join channel and start group chat
//        // If join  channel success, agoraKit triggers it's delegate function
//        // 'rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int)'
//        agoraKit.joinChannel(byToken: token, channelId: channelName, info: nil, uid: 0, joinSuccess: nil)
//        
//        // Step 6, set speaker audio route
//        agoraKit.setEnableSpeakerphone(true)
//    }
//    
//    
//    func setIdleTimerActive(_ active: Bool) {
//        UIApplication.shared.isIdleTimerDisabled = !active
//    }
//    
//}
//
//// MARK: Chanel
//extension LiveWinnerViewController {
//    func createChannel() {
//        let errorHandle = { [weak self] (action: UIAlertAction) in
//            guard let strongSelf = self else {
//                return
//            }
//        }
//        
//        guard let rtmChannel = AgoraRtm.kit?.createChannel(withId: channelName, delegate: self) else {
//            // showAlert("join channel fail", handler: errorHandle)
//            return
//        }
//        
//        rtmChannel.join { [weak self] (error) in
//            if error != .channelErrorOk, let strongSelf = self {
//                //  strongSelf.showAlert("join channel error: \(error.rawValue)", handler: errorHandle)
//            }
//        }
//        
//        self.rtmChannel = rtmChannel
//    }
//    
//    func leaveRtmChannel() {
//        rtmChannel?.leave { (error) in
//        }
//    }
//}
//
//// MARK: - AgoraRtcEngineDelegate
//extension LiveWinnerViewController: AgoraRtcEngineDelegate {
//    
//    /// Occurs when the first local video frame is displayed/rendered on the local video view.
//    ///
//    /// Same as [firstLocalVideoFrameBlock]([AgoraRtcEngineKit firstLocalVideoFrameBlock:]).
//    /// @param engine  AgoraRtcEngineKit object.
//    /// @param size    Size of the first local video frame (width and height).
//    /// @param elapsed Time elapsed (ms) from the local user calling the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK calls this callback.
//    ///
//    /// If the [startPreview]([AgoraRtcEngineKit startPreview]) method is called before the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, then `elapsed` is the time elapsed from calling the [startPreview]([AgoraRtcEngineKit startPreview]) method until the SDK triggers this callback.
//    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
//        if let selfSession = videoSessions.first {
//            selfSession.updateInfo(resolution: size)
//        }
//        
//    }
//    
//    /// Reports the statistics of the current call. The SDK triggers this callback once every two seconds after the user joins the channel.
//    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
//        if let selfSession = videoSessions.first {
//            selfSession.updateChannelStats(stats)
//        }
//    }
//    
//    
//    /// Occurs when the first remote video frame is received and decoded.
//    /// - Parameters:
//    ///   - engine: AgoraRtcEngineKit object.
//    ///   - uid: User ID of the remote user sending the video stream.
//    ///   - size: Size of the video frame (width and height).
//    ///   - elapsed: Time elapsed (ms) from the local user calling the joinChannelByToken method until the SDK triggers this callback.
//    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
//        
//        guard videoSessions.count <= 1 else {
//            return
//        }
//        
//        let userSession = videoSession(of: uid)
//        userSession.updateInfo(resolution: size)
//        agoraKit.setupRemoteVideo(userSession.canvas)
//        //agoraKit.switchCamera()
//    }
//    
//    /// Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel. Same as [userOfflineBlock]([AgoraRtcEngineKit userOfflineBlock:]).
//    ///
//    /// There are two reasons for users to be offline:
//    ///
//    /// - Leave a channel: When the user/host leaves a channel, the user/host sends a goodbye message. When the message is received, the SDK assumes that the user/host leaves a channel.
//    /// - Drop offline: When no data packet of the user or host is received for a certain period of time (20 seconds for the Communication profile, and more for the Live-broadcast profile), the SDK assumes that the user/host drops offline. Unreliable network connections may lead to false detections, so Agora recommends using a signaling system for more reliable offline detection.
//    ///
//    ///  @param engine AgoraRtcEngineKit object.
//    ///  @param uid    ID of the user or host who leaves a channel or goes offline.
//    ///  @param reason Reason why the user goes offline, see AgoraUserOfflineReason.
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
//        print("Offline")
//        //        AlertController.alert(title: "", message: "Live streaming has been finished.", buttons: ["Ok"]) { (alert, index) in
//        //            self.navigationController?.popViewController(animated: true)
//        //        }
//        
//        getLiveStatus(hud: false)
//    }
//    
//    /// Reports the statistics of the video stream from each remote user/host.
//    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
//        if let session = getSession(of: stats.uid) {
//            session.updateVideoStats(stats)
//        }
//    }
//    
//    /// Reports the statistics of the audio stream from each remote user/host.
//    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
//        if let session = getSession(of: stats.uid) {
//            session.updateAudioStats(stats)
//        }
//    }
//    
//    /// Reports a warning during SDK runtime.
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
//        print("warning code: \(warningCode.description)")
//        
//    }
//    
//    /// Reports an error during SDK runtime.
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
//        print("error code: \(errorCode.description)")
//        
//    }
//}
//
//// MARK: AgoraRtmChannelDelegate
//extension LiveWinnerViewController: AgoraRtmChannelDelegate,AgoraRtmDelegate {
//    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
//        DispatchQueue.main.async { [unowned self] in
//            print("join::---\(member.userId) join")
//        }
//    }
//    
//    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
//        DispatchQueue.main.async { [unowned self] in
//            if "\(member.userId)" == "Admin" {
//                AlertController.alert(title: "", message: "Live streaming has been finished.", buttons: ["Ok"]) { (alert, index) in
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }
//        }
//    }
//    
//    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
//        
//        if toDictonary(message.text)?.count ?? 0 > 0 {
//            appendMessage(user: member.userId, content: message.text, dict: toDictonary(message.text)!)
//        } else {
//            appendMessage(user: member.userId, content: message.text)
//            
//        }
//    }
//    
//    func channel(_ channel: AgoraRtmChannel, memberCount count: Int32) {
//        self.viewsLabel.text = "Views \(count - 1)"
//    }
//}
//
//extension LiveWinnerViewController {
//    func getSession(of uid: UInt) -> VideoSession? {
//        for session in videoSessions {
//            if session.uid == uid {
//                return session
//            }
//        }
//        return nil
//    }
//    
//    func videoSession(of uid: UInt) -> VideoSession {
//        if let fetchedSession = getSession(of: uid) {
//            return fetchedSession
//        } else {
//            let newSession = VideoSession(uid: uid)
//            newSession.canvas.view = remoteVideo
//            videoSessions.append(newSession)
//            return newSession
//        }
//    }
//}
//
//extension LiveWinnerViewController : UITextViewDelegate {
//    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        guard var str = textView.text, let range = Range(range, in: str) else { return true }
//        str = str.replacingCharacters(in: range, with: text)
//        
//        let numLines = Double(textView.contentSize.height) / Double(textView.font?.lineHeight ?? 16)
//        textView.isScrollEnabled = numLines > 6
//        self.view.layoutSubviews()
//        DispatchQueue.main.async {
//            // self.scrollToBottom()
//        }
//        
//        if str.length > 256 {
//            return false
//        }
//        
//        return true
//    }
//    
//    public func textViewDidEndEditing(_ textView: UITextView) {
//        textView.isScrollEnabled = false
//    }
//    
//}
//
//
//extension LiveWinnerViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return list.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastTableViewCell", for: indexPath) as! BroadcastTableViewCell
//        let obj = list[indexPath.row]
//        
//        cell.messageLabel.text = obj.text
//        if obj.userId == "54" {
//            cell.profileImageView.image = UIImage(named: "sizzle_card")
//        }else {
//            if let url = URL(string: obj.image) {
//                cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
//            }
//        }
//        
//        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
//        return cell
//    }
//    
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    
//}
//
//// MARK: Send Message
//extension LiveWinnerViewController {
//    func send(message: String) {
//        let sent = { [unowned self] (state: Int) in
//            guard state == 0 else {
//                
//                AlertController.alert(title: "", message: "send message error: \(state)", buttons: ["OK"]) { (alert, index) in
//                    self.view.endEditing(true)
//                }
//                return
//            }
//            
//            guard let current = AgoraRtm.current else {
//                return
//            }
//            
//        }
//        
//        // self.appendMessage(user: "Prem", content: message)
//        var param = [String: Any]()
//        param["message"] = message
//        param["name"] = AuthManager.shared.loggedInUser?.first_name?.count ?? 0 > 0 ?   AuthManager.shared.loggedInUser?.first_name : "Annonymous"
//        param["image"] = AuthManager.shared.loggedInUser?.image?.count ?? 0 > 0 ? AuthManager.shared.loggedInUser?.image : "zx"
//        param["user_id"] = AuthManager.shared.loggedInUser?.user_id?.count ?? 0 > 0 ? AuthManager.shared.loggedInUser?.user_id : "0"
//        
//        let totalMsg = toJSONString(param)!
//        let rtmMessage = AgoraRtmMessage(text: totalMsg)
//        rtmChannel?.send(rtmMessage) { (error) in
//            if error == .errorOk {
//                self.appendMessage(user: AuthManager.shared.loggedInUser?.username ?? "Annonymous", content: message, dict: param)
//            }
//            sent(error.rawValue)
//        }
//    }
//    
//    func appendMessage(user: String, content: String, dict: [String: Any] = [String: Any]() ) {
//        
//        if dict.count > 0 {
//            DispatchQueue.main.async { [unowned self] in
//                let msg = Message(userId: dict["user_id"] as! String, text: dict["message"] as! String, image: dict["image"] as! String)
//                self.list.insert(msg, at: 0)
//                
//                let end = IndexPath(row: 0, section: 0)
//                if msg.userId == AuthManager.shared.loggedInUser?.user_id {
//                    self.textView.text = ""
//                }
//                self.tableView.reloadData()
//                self.tableView.scrollToRow(at: end, at: .top, animated: true)
//            }
//        }else {
//            let msg = Message(userId: user, text: content, image: "")
//            self.list.insert(msg, at: 0)
//            
//            let end = IndexPath(row: 0, section: 0)
//            if msg.userId == AuthManager.shared.loggedInUser?.user_id {
//                self.textView.text = ""
//            }
//            self.tableView.reloadData()
//            self.tableView.scrollToRow(at: end, at: .top, animated: true)
//        }
//        self.textView.text = ""
//    }
//}
//
//
//
//extension LiveWinnerViewController {
//    func getLiveStatus(hud: Bool = true){
//        var param = [String: Any]()
//        param["token"] = token
//        
//        WebServices.checkLiveStatus(params: param, loader: hud) { (response) in
//            if let obj = response?.object {
//                if obj.flag == 1 {
//                    self.setupWebView()
//                    self.updateLiveStatus(status: true)
//                    
//                }else {
//                    self.viewsLabel.isHidden = true
//                    AlertController.alert(title: "", message: "Live streaming has been finished.", buttons: ["Ok"]) { (alert, index) in
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//            }
//        }
//    }
//    
//    func updateLiveStatus(status: Bool){
//        var param = [String: Any]()
//        param["token"] = token
//        param["flag"] = status ? "1" : "0"
//        param["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
//        
//        WebServices.updateLiveStatus(params: param) { (response) in
//            
//        }
//    }
//}
//
//
//extension LiveWinnerViewController {
//    
//    func toJSONString(_ dict: [AnyHashable : Any]?) -> String? {
//        var _: Error?
//        var data: Data? = nil
//        do {
//            if let dict = dict {
//                data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
//            }
//        } catch {
//        }
//        var jsonString: String? = nil
//        if let data = data {
//            jsonString = String(data: data, encoding: .utf8)
//        }
//        return jsonString
//    }
//    
//    func toDictonary(_ jsonString: String?) -> [String : Any]? {
//        let data = jsonString?.data(using: .utf8)
//        var json: [AnyHashable : Any]? = nil
//        do {
//            if let data = data {
//                json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
//            }
//        } catch {
//        }
//        return json as? [String : Any]
//    }
//}
//
//
//
//
//struct Message {
//    var userId: String
//    var text: String
//    var image: String
//}
