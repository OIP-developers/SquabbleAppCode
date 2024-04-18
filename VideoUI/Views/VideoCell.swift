//
//  VideoCell.swift
//  VideoUI
//
//  Created by PT.Koanba on 10/09/22.
//

import UIKit
import RxSwift
import SDWebImage
import AVFoundation
import MediaPlayer

protocol VideoCellDelegate: AnyObject {
    func didTapButton(in cell: VideoCell)
}


public final class VideoCell: UICollectionViewCell {
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy) // Choose the style of haptic feedback

    weak var delegate: VideoCellDelegate?

    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var bottomConstTagLbl: NSLayoutConstraint!
    
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var standingStack: UIStackView! // installed
    @IBOutlet weak var downStack: UIStackView! // installed
    
    @IBOutlet weak var downStackSV: UIStackView!
    
    @IBOutlet weak var standingStackSV: UIStackView!
    @IBOutlet weak var btnsView: UIView!
    
    @IBOutlet weak var captionsView: Gradient!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var tagsLbl: UILabel!
    
    @IBOutlet weak var filterStackView: UIStackView!
    @IBOutlet weak var plusBtnIcon: UIButton!
    
    @IBOutlet weak var generalBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var voteBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var giftBtn: UIButton!
    
    @IBOutlet private(set) public var videoContainer: UIView!
    
    @IBOutlet weak var playPauseIV: UIImageView!
    @IBOutlet weak var replayBtn: UIButton!
    
    private(set) public lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspectFill
        videoContainer.layer.addSublayer(layer)
        return layer
    }()
    var isPlaying = false
    var isfiredOnce = false
    //var isMuted = false//
    var profilePic = ""

    @IBOutlet weak var thumbnailIV: UIImageView!
    
    @IBOutlet private(set) public var videoRetryButton: UIButton!
    @IBOutlet private(set) public var videoLoadingIndicator: UIActivityIndicatorView!
    
    var onRetry: (() -> Void)?

    var onHomePressed: (() -> Void)?

    var cellController: VideoCellController?


    public override func layoutSubviews() {
        super.layoutSubviews()
        
        addSwipe()
        setupSlider()
        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture: )))
        muteBtn.addGestureRecognizer(longPress)
        
        playerLayer.frame = videoContainer.bounds
        thumbnailIV.frame = UIScreen.main.bounds
        btnsView.frame = videoContainer.bounds
        videoLoadingIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        
        //messageBtn.didMoveToSuperview()
        //muteBtn.didMoveToSuperview()
        
        _ = AppFunctions.generalPublisher.subscribe(onNext: {[weak self] val in
            if val == "UNLIKED_VIDEO" {
                self?.voteBtn.tintColor = .systemGray6
            } else if val == "LIKED_VIDEO" {
                self?.voteBtn.tintColor = UIColor(named: "RED")
            }
            self?.setNeedsLayout()
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
        _ = AppFunctions.generalPublisher.subscribe(onNext: {[weak self] val in
            if val == "UNFOLLOWED" {
                self?.followBtn.tintColor = .systemGray6
            } else if val == "FOLLOWED" {
                self?.followBtn.tintColor = UIColor(named: "RED")
            }
            self?.setNeedsLayout()
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
        if AppFunctions.getMute() {
            muteBtn.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
            self.playerLayer.player?.volume = 10
        } else {
            muteBtn.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            self.playerLayer.player?.volume = 0
        }
        
        standingStack.layer.cornerRadius = 5
        downStack.layer.cornerRadius = 5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        contentView.addGestureRecognizer(tap)
        
    }
    
    func makeVertical(slider: UISlider) {
        slider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
    }
    
    func setupSlider() {
        // Set up the slider
        
        makeVertical(slider: volumeSlider)

        volumeSlider.minimumValue = 0.0
        volumeSlider.maximumValue = 1.0
        volumeSlider.value = self.playerLayer.player?.volume ?? 0.0
        
        // Add an action to handle value changes in the slider
        volumeSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    // Action method to handle slider value changes
    @objc func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Float(sender.value) // Get the current value of the slider

        if currentValue == 0.0 {
            AppFunctions.saveMute(val: false) // slash
            cellController?.muteButtonLongPressed()
        } else {
            AppFunctions.saveMute(val: true) // wave
            cellController?.muteButtonLongPressed()
        }
        self.playerLayer.player?.volume = currentValue
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
            showVolumeView()
        }
    }
    
    func showVolumeView() {
        volumeView.isHidden = false
        
        // After a delay of 3 seconds, making the view visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.volumeView.isHidden = true
        }
    }
    
    func updateMuteButton() {
        DispatchQueue.main.async {
            if AppFunctions.getMute() {
                self.muteBtn.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
            } else {
                self.muteBtn.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("TAPPED")
        if self.playerLayer.player != nil {
            if isPlaying {
                isPlaying = false
                self.playerLayer.player?.pause()
                playPauseIV.image = UIImage(named: "icn_play")
                playPauseIV.fadeIn()
            } else {
                isPlaying = true
                playPauseIV.image = UIImage(named: "icn_pause")
                self.playerLayer.player?.play()
                playPauseIV.fadeOut()
            }
        }
    }
    
    @IBAction private func retryButtonTapped() {
        //onRetry?()
    }
    @IBAction func plusBtnPressed(_ sender: Any) {
        if plusBtnIcon.imageView?.image == UIImage(systemName: "plus") {
            showHidePopupContents(value: false)
        } else {
            AppFunctions.generalPublisher.onNext("profile")
        }
    }
    
    @IBAction func genralBtnPressed(_ sender: Any) {
        filterStackView.fadeIn()
    }
    
    @IBAction func crossBtnPressed(_ sender: Any) {
        filterStackView.fadeOut()
    }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.playerLayer.player = nil
        isPlaying = false
        showHidePopupContents(value: false)
    }
    
    func setVideo(with player: AVPlayer, vidModel: VideosModel = VideosModel()) {
        self.playerLayer.player = player
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        _ =  self.playerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1, preferredTimescale: 1), queue: .main, using: {[weak self] (time) in
            //print("TIME: \(time)")
            if time.value > 0 {
                
                self?.videoLoadingIndicator.stopAnimating()
                //self?.thumbnailIV.isHidden = true
            }
        })
        isPlaying = true
    }
    
    func releasePlayerForReuse() {
    }
    
    func showHidePopupContents(value: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                if !value {
                    self.bottomConstTagLbl.constant = 130
                    self.plusBtnIcon.imageView?.layer.cornerRadius = self.plusBtnIcon.frame.height / 2
                    self.plusBtnIcon.layer.cornerRadius = self.plusBtnIcon.frame.height / 2
                    //self.plusBtnIcon.layer.borderColor = UIColor(named: "RED")?.cgColor
                    if self.profilePic != "nil" {
                        if let url = URL(string: self.profilePic ) {
                            self.plusBtnIcon.sd_setImage(with: url, for: .normal , placeholderImage: UIImage(named: "ic_logo")) { (image, error, imageCacheType, url) in }
                        } else {
                            self.plusBtnIcon.setImage(UIImage(named: "ic_logo"), for: .normal)
                        }
                    }
                    self.captionsView.isHidden = false
                    
                } else {
                    self.captionsView.isHidden = true
                    self.bottomConstTagLbl.constant = 74
                    self.plusBtnIcon.setImage(UIImage(systemName: "plus"), for: .normal)
                    self.plusBtnIcon.layer.cornerRadius = 0
                    self.plusBtnIcon.imageView?.layer.cornerRadius = 0
                    self.plusBtnIcon.layer.borderWidth = 0
                }
                self.downStack.subviews.forEach { btn in
                    btn.isHidden = value
                }
                self.standingStack.subviews.forEach { btn in
                    btn.isHidden = value
                }
            }
            if value {
                return
            }
            _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: false)
        }
    }
    
    @objc func fireTimer() {
        if !isfiredOnce {
            print("fire")
            isfiredOnce = true
            showHidePopupContents(value: true)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
    }
    
    
    func addSwipe() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
            gesture.direction = direction
            self.addGestureRecognizer(gesture)
        }
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        print(sender.direction.rawValue)
        if (sender.direction.rawValue == 2) {
            delegate?.didTapButton(in: self)
            AppFunctions.generalPublisher.onNext("profile")
        } else if (sender.direction.rawValue == 1) {
            delegate?.didTapButton(in: self)
            AppFunctions.generalPublisher.onNext("vote")
        }
        // 2 left
        // 1 right
    }
    
    ///Stack Btn Actions
    ///

    @IBAction func homeBtnPressed(_ sender: Any) {
        AppFunctions.generalPublisher.onNext("home")
    }
    
    @IBAction func muteBtnPressed(_ sender: Any) {
        Logs.show(message: "Normal Tap")
        cellController?.muteButtonPressed()

    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        delegate?.didTapButton(in: self)

        AppFunctions.generalPublisher.onNext("share")
    }
    
    @IBAction func voteBtnPressed(_ sender: Any) {
        delegate?.didTapButton(in: self)

        AppFunctions.generalPublisher.onNext("vote")
    }
    
    @IBAction func messageBtnPressed(_ sender: Any) {
        delegate?.didTapButton(in: self)

        AppFunctions.generalPublisher.onNext("message")
    }
    
    @IBAction func giftBtnPressed(_ sender: Any) {
        delegate?.didTapButton(in: self)

        AppFunctions.generalPublisher.onNext("gift")

    }
    @IBAction func followBtnPressed(_ sender: Any) {
        delegate?.didTapButton(in: self)

        AppFunctions.generalPublisher.onNext("follow")

    }
    
    
    @IBAction func generalFilterBtnPressed(_ sender: Any) {
        filterKey = "general"
        generalBtn.setTitle("General", for: .normal)
        AppFunctions.generalPublisher.onNext("general")
        filterStackView.fadeOut()

    }
    
    @IBAction func followingFilterBtnPressed(_ sender: Any) {
        filterKey = "following"
        generalBtn.setTitle("Following", for: .normal)
        AppFunctions.generalPublisher.onNext("following")
        filterStackView.fadeOut()

    }
    
    @IBAction func trendingFilterBtnPressed(_ sender: Any) {
        filterKey = "trend"
        generalBtn.setTitle("Trending", for: .normal)
        AppFunctions.generalPublisher.onNext("trend")
        filterStackView.fadeOut()

    }
}
extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
