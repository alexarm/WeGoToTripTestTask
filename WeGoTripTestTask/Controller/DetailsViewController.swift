import UIKit
import Foundation
import AVFoundation

class DetailsViewController: SwipeDownViewController {
    
    var tour: Tour?
    var currentStep: Int?
    
    let audioPlayer = AudioPlayer.sharedInstance
    var playerObserver: Any?
    var wasPlaying = false
    
    @IBOutlet var tourTitleLabel: UILabel!
    @IBOutlet var tourDescriptionTextView: UITextView!
    
    @IBOutlet var playerView: UIView!
    @IBOutlet var audioDescripyionLabel: UILabel!
    @IBOutlet var audioProgress: UISlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var remainingTimeLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var gobackwardButton: UIButton!
    @IBOutlet var goforwardButton: UIButton!
    @IBOutlet var changeSpeedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tourTitleLabel.text = tour?.title
        tourDescriptionTextView.text = tour?.description
        
        playerView.layer.cornerRadius = 10
        playerView.layer.shadowColor = UIColor.lightGray.cgColor
        playerView.layer.shadowOpacity = 1
        playerView.layer.shadowOffset = .zero
        playerView.layer.shadowRadius = 5
        
        playPauseButton.layer.cornerRadius = playPauseButton.frame.height / 2
        
        let gobackwardImage = UIImage(systemName: "gobackward.10")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        gobackwardButton.setBackgroundImage(gobackwardImage, for: .normal)
        let goforwardImage = UIImage(systemName: "goforward.10")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        goforwardButton.setBackgroundImage(goforwardImage, for: .normal)
        
        updateChangeSpeedButtonText()
        
        audioDescripyionLabel.text = audioPlayer.description
        updatePlayPauseButtonImage()
        
        updateProgress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addPeriodicTimeObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deletePeriodicTimeObserver()
    }
    
    @IBAction func closeDetails(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func updatePlayPauseButtonImage() {
        if (audioPlayer.isPlaying) {
            let pauseImage = UIImage(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            playPauseButton.setImage(pauseImage, for: .normal)
        } else {
            let playImage = UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            playPauseButton.setImage(playImage, for: .normal)
        }
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        if !(audioPlayer.isPlaying) {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
        updatePlayPauseButtonImage()
    }
    
    @IBAction func gobackwardButtonPressed(_ sender: UIButton) {
        audioPlayer.skipAudio(by: -10)
    }
    
    @IBAction func goforwardButtonPressed(_ sender: UIButton) {
        audioPlayer.skipAudio(by: 10)
    }
    
    func updateChangeSpeedButtonText() {
        switch audioPlayer.currentSpeed {
        case .normal:
            changeSpeedButton.setTitle("1x", for: .normal)
        case .x2:
            changeSpeedButton.setTitle("2x", for: .normal)
        }
    }
    
    @IBAction func changeSpeedButtonPressed(_ sender: UIButton) {
        audioPlayer.changeSpeed()
        updateChangeSpeedButtonText()
    }
    
    @IBAction func sliderValueChangeStarted(_ sender: UISlider) {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            deletePeriodicTimeObserver()
            wasPlaying = true
        }
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        let currentTime = Int(audioProgress.value)
        let duration = Int(audioPlayer.duration?.seconds ?? 0)
        
        let remainingTime = duration - currentTime
        currentTimeLabel.text = String(format: "%01i:%02i", (currentTime % 3600) / 60, (currentTime % 3600) % 60)
        remainingTimeLabel.text = String(format: "%01i:%02i", (remainingTime % 3600) / 60, (remainingTime % 3600) % 60)
    }
    
    @IBAction func sliderValueChangeFinished(_ sender: UISlider) {
        let position = CMTimeMakeWithSeconds(Double(audioProgress.value), preferredTimescale: 1000)
        audioPlayer.player.seek(to: position) { completed in
            if completed {
                if self.wasPlaying == true {
                    self.audioPlayer.play()
                    self.wasPlaying = false
                }
            }
        }
        
        addPeriodicTimeObserver()
    }
    
    @objc func updateProgress() {
        let currentTime = Int(audioPlayer.currentTime.seconds)
        let duration = Int(audioPlayer.duration?.seconds ?? 0)
        
        audioProgress.minimumValue = 0.0
        audioProgress.maximumValue = Float(duration)
        audioProgress.setValue(Float(currentTime), animated: false)
        
        let remainingTime = duration - currentTime
        currentTimeLabel.text = String(format: "%01i:%02i", (currentTime % 3600) / 60, (currentTime % 3600) % 60)
        remainingTimeLabel.text = String(format: "%01i:%02i", (remainingTime % 3600) / 60, (remainingTime % 3600) % 60)
        
        updatePlayPauseButtonImage()
    }
    
    func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerObserver = audioPlayer.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            self.updateProgress()
        }
    }
    
    func deletePeriodicTimeObserver() {
        if let observer = playerObserver {
            audioPlayer.player.removeTimeObserver(observer)
        }
    }
    
    @IBSegueAction func goToRemainingSteps(_ coder: NSCoder, sender: Any?) -> ListOfRemainingStepsViewController? {
        return ListOfRemainingStepsViewController(coder: coder, tour: tour!, currentStep: currentStep!)
    }
}
