//
//  PlayerManager.swift
//  AppMusic
//
//  Created by le.n.t.trung on 14/10/2022.
//

import Foundation
import AVFoundation

final class PlayerManager: NSObject {
    static let shared = PlayerManager()
    var player: AVAudioPlayer?
    
    private override init() {}
    
    func playSound(_ songName: String) {
        guard let url = Bundle.main.url(forResource: songName, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }
            
            player.delegate = self
            player.prepareToPlay()

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func prepareToPlay() {
        player?.prepareToPlay()
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.stop()
    }
    
    func pause() {
        player?.pause()
    }
    
    func getDuration() -> TimeInterval {
        return player?.duration ?? 0
    }
    
    func getCurrentTime() -> TimeInterval {
        return player?.currentTime ?? 0
    }
    
    func getDeviceCurrentTime() -> TimeInterval {
        return player?.deviceCurrentTime ?? 0
    }
    
    func setCurrentTime(_ time: TimeInterval) {
        player?.currentTime = time
    }
}

extension PlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            if flag == true{
                player.currentTime = 0
                player.prepareToPlay()
                player.play()
            }
    }
}
