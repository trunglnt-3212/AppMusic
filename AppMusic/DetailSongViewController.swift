//
//  ViewController.swift
//  AppMusic
//
//  Created by le.n.t.trung on 13/10/2022.
//

import UIKit
import AVFoundation
import MediaPlayer

final class DetailSongViewController: UIViewController {
    
    @IBOutlet private weak var songNameLabel: UILabel!
    @IBOutlet private weak var songPerformerLabel: UILabel!
    @IBOutlet private weak var songImageView: UIImageView!
    @IBOutlet private weak var prevButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var pausePlayButton: UIButton!
    @IBOutlet private weak var buttonSlider: UISlider!
    @IBOutlet private weak var timeLabel: UILabel!
    
    private var isPlay = true
    private var currentIndex = 0
    private var listSong = [Song]()
    private let playerManager = PlayerManager.shared
    private var currentTime: TimeInterval = 0
    private var timer: Timer?
    private var durationTime: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        initListSong()
        updateInfoCurrentSong()
        configPlayerTime()
        addActionsToControlCenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            playerManager.stop()
        }
    }
    
    func bindData(listSong: [Song], currentIndex: Int) {
        self.listSong = listSong
        self.currentIndex = currentIndex
    }

    private func configView() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    private func initListSong() {
        pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        listSong.append(Song(name: "Tong phu", performer: "Keyo", image: "image_0_song", audio: "TongPhuSong"))
        listSong.append(Song(name: "Biet tim dau", performer: "Tuan Hung", image: "image_1_song", audio: "BietTimDauSong"))
        listSong.append(Song(name: "Vo tan", performer: "Trinh Thang Binh", image: "image_2_song", audio: "VoTanSong"))
    }
    
    private func updateInfoCurrentSong() {
        // Update in UI in App
        songNameLabel.text = listSong[currentIndex].name
        songPerformerLabel.text = listSong[currentIndex].performer
        songImageView.image = UIImage(named: listSong[currentIndex].image)
        pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        
        playerManager.playSound(listSong[currentIndex].audio)
        
        durationTime = setUpFormatTime(playerManager.getDuration())
        timeLabel.text = "00:00 / " + (durationTime ?? "00:00")
        timeLabel.textColor = .white
        
        // Update UI in Lock Screen
        guard let image = UIImage(named: listSong[currentIndex].image) else {
            return
        }
        let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: listSong[currentIndex].name,
            MPMediaItemPropertyArtist: listSong[currentIndex].performer,
            MPMediaItemPropertyArtwork: artwork
        ]
    }
    
    private func configPlayerTime() {
        buttonSlider.maximumValue = Float(playerManager.getDuration())
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: Double(Int(buttonSlider.value)),
                                     target: self,
                                     selector: #selector(DetailSongViewController.updateSlider),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    private func handlePlayOrPauseTap() {
        if (isPlay) {
            pausePlayButton.setImage(UIImage(named: "icon_play"), for: .normal)
            currentTime = playerManager.getDeviceCurrentTime()
            playerManager.pause()
        }
        else {
            pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
            playerManager.play()
        }
        isPlay.toggle()
    }
    
    private func handlePrevTap() {
        switch currentIndex {
        case 0:
            currentIndex = listSong.count - 1
        default:
            currentIndex -= 1
        }
        updateInfoCurrentSong()
    }
    
    private func handleNextTap() {
        switch currentIndex {
        case listSong.count - 1:
            currentIndex = 0
        default:
            currentIndex += 1
        }
        updateInfoCurrentSong()
    }
    
    private func setUpFormatTime(_ duration: TimeInterval) -> String {
        let secondDuration = Int(duration) % 60
        let minuteDuration = Int(duration) / 60
        let minuteString = minuteDuration < 10 ? String("0\(minuteDuration)") : String(minuteDuration)
        let secondString = secondDuration < 10 ? String("0\(secondDuration)") : String(secondDuration)
        return minuteString + ":" + secondString
    }
    
    @objc private func updateSlider() {
        buttonSlider.value = Float(playerManager.getCurrentTime())
        timeLabel.text = setUpFormatTime(playerManager.getCurrentTime()) + " / " + (durationTime ?? "00:00")
    }
    
    @IBAction func prevTapAction(_ sender: Any) {
        handlePrevTap()
    }
    
    @IBAction func nextTapAction(_ sender: Any) {
        handleNextTap()
    }
    
    @IBAction func didTapPauseOrPlayAction(_ sender: Any) {
        handlePlayOrPauseTap()
    }
    
    @IBAction func didChangeSliderAction(_ sender: Any) {
        playerManager.stop()
        playerManager.setCurrentTime(TimeInterval(buttonSlider.value))
        if (isPlay) {
            playerManager.prepareToPlay()
            playerManager.play()
        }
    }
}

extension DetailSongViewController {
    private func addActionsToControlCenter() {
        addActionToPlayCommand()
        addActionToPauseCommnd()
        addActionToPreviousCommand()
        addActionToNextCommand()
    }
    
    private func addActionToPlayCommand() {
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget(self,
                                                             action: #selector(playOrPauseButtonTapped))
    }
    
    private func addActionToPauseCommnd() {
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self,
                                                              action: #selector(playOrPauseButtonTapped))
    }
    
    private func addActionToPreviousCommand() {
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self,
                                                                      action: #selector(previousButtonTapped))
    }
    
    private func addActionToNextCommand() {
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self,
                                                                  action: #selector(nextButtonTapped))
    }
    
    @objc
    private func playOrPauseButtonTapped() -> MPRemoteCommandHandlerStatus {
        handlePlayOrPauseTap()
        return .success
    }
    
    @objc
    private func previousButtonTapped() -> MPRemoteCommandHandlerStatus {
        handlePrevTap()
        return .success
    }
    
    @objc
    private func nextButtonTapped() -> MPRemoteCommandHandlerStatus {
        handleNextTap()
        return .success
    }
}
