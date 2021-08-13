import UIKit
import AVFoundation

class MainScreenViewController: UIViewController {
    
    let networkController = NetworkController()

    var tour: Tour
    var currentStep: Int
    var playerObserver: Any?
    
    @IBOutlet var buttonsView: UIView!
    
    @IBOutlet var stepProgress: UIProgressView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var detailsButton: UIButton!
    @IBOutlet var stepLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var imageScroll: UIScrollView!
    @IBOutlet var imagePageControl: UIPageControl!
    
    @IBOutlet var stepDescriptionLabel: UILabel!
    @IBOutlet var playStepButton: UIButton!
    
    @IBOutlet var playerView: UIView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var audioProgress: UIProgressView!
    @IBOutlet var audioDescription: UILabel!
    @IBOutlet var gobackwardButton: UIButton!
    @IBOutlet var goforwardButton: UIButton!
    @IBOutlet var changeSpeedButton: UIButton!
    
    let audioPlayer = AudioPlayer.sharedInstance

    init?(coder: NSCoder, tour: Tour, stepNumber currentStep: Int) {
        self.tour = tour
        self.currentStep = currentStep
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        imageScroll.delegate = self
        
        buttonsView.backgroundColor = UIColor.clear
        buttonsView.isOpaque = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCloseDetails(_:)))
        playerView.addGestureRecognizer(tapGesture)
        
        stepProgress.progress = Float(currentStep + 1) / Float(tour.steps.count)
        stepLabel.text = "STEP \(currentStep + 1)/\(tour.steps.count)"
        titleLabel.text = tour.steps[currentStep].title
        
        imagePageControl.numberOfPages = tour.steps[currentStep].imageUrls.count
        
        setCarouselView(for: tour.steps[currentStep].imageUrls)
        
        stepDescriptionLabel.text = tour.steps[currentStep].description
        playStepButton.layer.cornerRadius = 10
        
        audioDescription.text = audioPlayer.description ?? "Включите экскурсию"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addPeriodicTimeObserver()
        updatePlayPauseButtonImage()
        updateChangeSpeedButtonText()
        
        if audioPlayer.isPlaying || audioPlayer.isPaused {
            audioProgress.progress = Float(CMTimeGetSeconds(audioPlayer.currentTime) / CMTimeGetSeconds(audioPlayer.duration!))
        } else {
            audioProgress.progress = 0.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deletePeriodicTimeObserver()
    }
    
    func setCarouselView(for images: [String]) {
        for i in 0..<images.count {
            
            let imageUrl = images[i]
            let encodedString = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedUrl = URL(string: encodedString)!
            
            let imageView = UIImageView()
            networkController.fetchImage(from: encodedUrl) { image in
                let image = image ?? UIImage(systemName: "photo")
                
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
            
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.imageScroll.frame.width, height: self.imageScroll.frame.height)
            
            let label = UILabel()
            label.clipsToBounds = true
            label.layer.cornerRadius = 10
            label.text = "\(i + 1)/\(images.count)"
            label.textAlignment = .center
            label.textColor = .white
            label.backgroundColor = .black
            label.alpha = 0.5
            let labexXPosition = (imageView.frame.width * CGFloat(i + 1)) - 60
            label.frame = CGRect(x: labexXPosition, y: imageView.frame.height - 40, width: 50.0, height: 25.0)
            
            imageScroll.contentSize.width = imageScroll.frame.width * CGFloat(i + 1)
            imageScroll.addSubview(imageView)
            imageScroll.addSubview(label)
        }
    }
    
    func updatePlayPauseButtonImage() {
        if (audioPlayer.isPlaying) {
            let pauseImage = UIImage(systemName: "pause.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            playButton.setImage(pauseImage, for: .normal)
        } else {
            let playImage = UIImage(systemName: "play.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            playButton.setImage(playImage, for: .normal)
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if !(audioPlayer.isPlaying) && !(audioPlayer.isPaused) {
            let currentAudio = tour.steps[currentStep].audioUrl
            let currentAudioDescription = tour.steps[currentStep].title
            audioPlayer.initPlayer(url: currentAudio, description: currentAudioDescription)
            addPeriodicTimeObserver()
            audioPlayer.play()
            audioDescription.text = audioPlayer.description
        } else if !(audioPlayer.isPlaying) {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
        updatePlayPauseButtonImage()
    }
    
    @IBAction func handleCloseDetails(_ sender: AnyObject) {
        performSegue(withIdentifier: "GoToDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDetails", let dvc = segue.destination as? DetailsViewController {
            dvc.tour = tour
            dvc.currentStep = currentStep
        }
    }
    
    @IBAction func closeStep(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playStep(_ sender: Any) {
        let currentAudio = tour.steps[currentStep].audioUrl
        let currentAudioDescription = tour.steps[currentStep].title
        deletePeriodicTimeObserver()
        
        audioPlayer.initPlayer(url: currentAudio, description: currentAudioDescription)
        
        addPeriodicTimeObserver()
        audioPlayer.play()
        
        updatePlayPauseButtonImage()
        audioDescription.text = audioPlayer.description
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
    
    func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerObserver = audioPlayer.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            let fraction = CMTimeGetSeconds(time) / CMTimeGetSeconds(self.audioPlayer.player.currentItem!.duration)
            self.audioProgress.progress = Float(fraction)
            self.updatePlayPauseButtonImage()
            self.updateChangeSpeedButtonText()
        }
    }
    
    func deletePeriodicTimeObserver() {
        if let observer = playerObserver {
            audioPlayer.player.removeTimeObserver(observer)
        }
    }
    
}

extension MainScreenViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imagePageControl.currentPage = Int(imageScroll.contentOffset.x) / Int(imageScroll.frame.width)
    }
}

