import Foundation
import AVFoundation

class AudioPlayer {
    public static var sharedInstance = AudioPlayer()
    var player = AVPlayer()
    var description: String?
    var currentSpeed: Speed = .normal
    
    var isPlaying: Bool {
        return player.rate != 0 && player.error == nil && duration != currentTime
    }
    
    var isPaused: Bool {
        return !isPlaying && player.currentItem != nil
    }
    
    var duration: CMTime? {
        return player.currentItem?.duration
    }
    
    var currentTime: CMTime {
        if let currentItem = player.currentItem {
            return currentItem.currentTime()
        } else {
            return CMTimeMakeWithSeconds(0, preferredTimescale: 1000)
        }
    }
    
    func initPlayer(url: String, description: String) {
        guard let url = URL(string: url) else { return }
        
        self.description = description
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playAudioBackground()
    }
    
    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("ERRRRRROR")
            print(error)
        }
    }
    
    func pause(){
        player.pause()
    }
    
    func play() {
        player.rate = currentSpeed.rawValue
    }
    
    func seek(to time: CMTime) {
        player.seek(to: time)
    }
    
    func skipAudio(by interval: TimeInterval) {
        if let currentItem = player.currentItem {
            let position = currentItem.currentTime().seconds + interval
            player.seek(to: CMTimeMakeWithSeconds(position, preferredTimescale: 1000))
        }
    }
    
    func changeSpeed(by rate: Float) {
        player.rate = rate
    }
    
    func changeSpeed() {
        switch currentSpeed {
        case .normal:
            currentSpeed = .x2
        case .x2:
            currentSpeed = .normal
        }
        if isPlaying {
            play()
        }
    }
}

enum Speed: Float {
    case normal = 1.0
    case x2 = 2.0
}
