//
//  ViewController.swift
//  AppMusic
//
//  Created by le.n.t.trung on 13/10/2022.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {
    
    @IBOutlet private weak var songNameLabel: UILabel!
    @IBOutlet private weak var songPerformerLabel: UILabel!
    @IBOutlet private weak var songImageView: UIImageView!
    @IBOutlet private weak var prevButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var pausePlayButton: UIButton!
    @IBOutlet private weak var sliderButton: UISlider!
    @IBOutlet private weak var timeLabel: UILabel!
    
    private var isPlay: Bool = true
    private var indexSong: Int = 0
    private var listSong: [Song] = []
    private let playerManager = PlayerManager.shared
    private var currentTime: TimeInterval = 0
    private var timer: Timer?
    private var durationTime: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initListSong()
        configCurrentSong()
        configPlayerTime()
    }
    
    private func initListSong() {
        pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        listSong.append(Song(name: "Tong phu", performer: "Keyo", image: "image_0_song", audio: "TongPhuSong"))
        listSong.append(Song(name: "Biet tim dau", performer: "Tuan Hung", image: "image_1_song", audio: "BietTimDauSong"))
        listSong.append(Song(name: "Vo tan", performer: "Trinh Thang Binh", image: "image_2_song", audio: "VoTanSong"))
    }
    
    private func configCurrentSong() {
        songNameLabel.text = listSong[indexSong].name
        songPerformerLabel.text = listSong[indexSong].performer
        songImageView.image = UIImage(named: listSong[indexSong].image)
        pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        
        playerManager.playSound(listSong[indexSong].audio)

        durationTime = setUpFormatTime(playerManager.getDuration())
        timeLabel.text = "00:00 / " + (durationTime ?? "00:00")
        timeLabel.textColor = .white
    }
    
    private func configPlayerTime() {
        sliderButton.maximumValue = Float(playerManager.getDuration())
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: Double(Int(sliderButton.value)), target: self, selector: #selector(ViewController.updateSlider), userInfo: nil, repeats: true)
    }
    
    
    private func setUpFormatTime(_ duration: TimeInterval) -> String {
        let secondDuration = Int(duration) % 60
        let minuteDuration = Int(duration) / 60
        let minuteString = minuteDuration < 10 ? String("0\(minuteDuration)") : String(minuteDuration)
        let secondString = secondDuration < 10 ? String("0\(secondDuration)") : String(secondDuration)
        return minuteString + ":" + secondString
    }
    
    @objc func updateSlider() {
        sliderButton.value = Float(playerManager.getCurrentTime())
        timeLabel.text = setUpFormatTime(playerManager.getCurrentTime()) + " / " + (durationTime ?? "00:00")
    }

    @IBAction func prevTap(_ sender: Any) {
        switch indexSong {
        case 0:
            indexSong = listSong.count - 1
        default:
            indexSong -= 1
        }
        configCurrentSong()
    }
    
    @IBAction func nextTap(_ sender: Any) {
        switch indexSong {
        case listSong.count - 1:
            indexSong = 0
        default:
            indexSong += 1
        }
        configCurrentSong()
    }
    
    @IBAction func didTapPauseOrPlay(_ sender: Any) {
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
    
    @IBAction func didChangeSlider(_ sender: Any) {
        playerManager.stop()
        playerManager.setCurrentTime(TimeInterval(sliderButton.value))
        if(isPlay){
            playerManager.prepareToPlay()
            playerManager.play()
        }
    }
    
}


