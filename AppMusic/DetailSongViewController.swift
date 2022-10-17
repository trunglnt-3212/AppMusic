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
    @IBOutlet private weak var sliderButton: UISlider!
    @IBOutlet private weak var timeLabel: UILabel!
    
    private var isPlay: Bool = true
    private var indexCurrentSong: Int = 0
    private var listSong: [Song] = []
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
    
    func bindListSong(_ listSong: [Song]) {
        self.listSong = listSong
    }
    
    func bindIndexCurrentSong(_ indexCurrentSong: Int) {
        self.indexCurrentSong = indexCurrentSong
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
        songNameLabel.text = listSong[indexCurrentSong].name
        songPerformerLabel.text = listSong[indexCurrentSong].performer
        songImageView.image = UIImage(named: listSong[indexCurrentSong].image)
        pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        
        playerManager.playSound(listSong[indexCurrentSong].audio)

        durationTime = setUpFormatTime(playerManager.getDuration())
        timeLabel.text = "00:00 / " + (durationTime ?? "00:00")
        timeLabel.textColor = .white
        
        // Update UI in Lock Screen
        let image = UIImage(named: listSong[indexCurrentSong].image)!
        let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                return image
        })
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: listSong[indexCurrentSong].name,
            MPMediaItemPropertyArtist: listSong[indexCurrentSong].performer,
            MPMediaItemPropertyArtwork: artwork
        ]
    }
    
    private func configPlayerTime() {
        sliderButton.maximumValue = Float(playerManager.getDuration())
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: Double(Int(sliderButton.value)), target: self, selector: #selector(DetailSongViewController.updateSlider), userInfo: nil, repeats: true)
    }
    
    private func handlePlayOrPauseTap() {
        if (isPlay){
            pausePlayButton.setImage(UIImage(named: "icon_play"), for: .normal)
            currentTime = playerManager.getDeviceCurrentTime()
            playerManager.pause()
        }
        else{
            pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
            playerManager.play()
        }
        isPlay = !isPlay
    }
    
    private func handlePrevTap() {
        switch indexCurrentSong {
        case 0:
            indexCurrentSong = listSong.count - 1
        default:
            indexCurrentSong -= 1
        }
        updateInfoCurrentSong()
    }
    
    private func handleNextTap() {
        switch indexCurrentSong {
            case listSong.count - 1:
                indexCurrentSong = 0
            default:
                indexCurrentSong += 1
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
        sliderButton.value = Float(playerManager.getCurrentTime())
        timeLabel.text = setUpFormatTime(playerManager.getCurrentTime()) + " / " + (durationTime ?? "00:00")
    }

    @IBAction func prevTap(_ sender: Any) {
        handlePrevTap()
    }
    
    @IBAction func nextTap(_ sender: Any) {
        handleNextTap()
    }
    
    @IBAction func didTapPauseOrPlay(_ sender: Any) {
        handlePlayOrPauseTap()
    }
    
    @IBAction func didChangeSlider(_ sender: Any) {
        playerManager.stop()
        playerManager.setCurrentTime(TimeInterval(sliderButton.value))
        if(isPlay){
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
            MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(playOrPauseButtonTapped))
    }

    private func addActionToPauseCommnd() {
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(playOrPauseButtonTapped))
    }

    private func addActionToPreviousCommand() {
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(previousButtonTapped))
    }

    private func addActionToNextCommand() {
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(nextButtonTapped))
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


