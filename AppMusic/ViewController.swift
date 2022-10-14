//
//  ViewController.swift
//  AppMusic
//
//  Created by le.n.t.trung on 13/10/2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    struct Song{
        var name: String
        var performer: String
        var image: String
        var audio: String
    }
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songPerformerLabel: UILabel!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBOutlet weak var sliderButton: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    
    var isPlay: Bool = true
    var indexSong: Int = 0
    var listSong: [Song] = []
    var player: AVAudioPlayer?
    var currentTime: TimeInterval = 0
    var timer: Timer?
    var currentSecond: Int?
    var currentMinute: Int?
    var durationTime: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Thiet lap image ban dau cho Play/Pause Button (Mac dinh la dang Play)
        pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        
        //Them danh sach bai hat
        listSong.append(Song(name: "Tong phu", performer: "Keyo", image: "image_0_song", audio: "TongPhuSong"))
        listSong.append(Song(name: "Biet tim dau", performer: "Tuan Hung", image: "image_1_song", audio: "BietTimDauSong"))
        listSong.append(Song(name: "Vo tan", performer: "Trinh Thang Binh", image: "image_2_song", audio: "VoTanSong"))
        
        //Gan thong tin bai hat hien tai
        configCurrentSong()
        //Play bai hat hien tai
        playSound(listSong[indexSong].audio)
        
        //Slider update theo bai hat
        sliderButton.maximumValue = Float(player?.duration ?? 0)
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: Double(Int(sliderButton.value)), target: self, selector: #selector(ViewController.updateSlider), userInfo: nil, repeats: true)
    }
    
    func configCurrentSong(){
        //Set thong tin bai hat
        songNameLabel.text = listSong[indexSong].name
        songPerformerLabel.text = listSong[indexSong].performer
        songImageView.image = UIImage(named: listSong[indexSong].image)
        pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        
        //Play bai hat
        playSound(listSong[indexSong].audio)
        
        //Set thoi gian chay bai hat
        let secondDuration = Int(player?.duration ?? 0) % 60
        let minuteDuration = Int(player?.duration ?? 0) / 60
        durationTime = setUpFormatTime(minuteDuration, secondDuration)
        timeLabel.text = "00:00 / " + (durationTime ?? "00:00")
        timeLabel.textColor = .white
    }
    
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
            if flag == true{
                player.currentTime = 0
                player.prepareToPlay()
                player.play()
            }
    }
    
    func setUpFormatTime(_ minute: Int, _ second: Int) -> String{
        let minuteString = minute < 10 ? String("0\(minute)") : String(minute)
        let secondString = second < 10 ? String("0\(second)") : String(second)
        return minuteString + ":" + secondString
    }
    
    @objc func updateSlider(){
        sliderButton.value = Float(player?.currentTime ?? 0)
        currentSecond = Int(player?.currentTime ?? 0) % 60
        currentMinute = Int(player?.currentTime ?? 0) / 60
        timeLabel.text = setUpFormatTime(currentMinute ?? 0, currentSecond ?? 0) + " / " + (durationTime ?? "00:00")
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
            currentTime = player?.deviceCurrentTime ?? 0
            player?.pause()
        }
        else{
            pausePlayButton.setImage(UIImage(named: "icon_pause"), for: .normal)
            player?.play()
        }
        isPlay = !isPlay
    }
    
    @IBAction func didChangeSlider(_ sender: Any) {
        player?.stop()
        player?.currentTime = TimeInterval(sliderButton.value)
        if(isPlay){
            player?.prepareToPlay()
            player?.play()
        }
    }
    
}

