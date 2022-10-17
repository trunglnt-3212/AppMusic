//
//  ListSongViewController.swift
//  AppMusic
//
//  Created by le.n.t.trung on 17/10/2022.
//

import UIKit

final class ListSongViewController: UIViewController {
    
    @IBOutlet private weak var listSongTable: UITableView!
    
    private var listSong: [Song] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        initListSong()
        listSongTable.reloadData()
    }
    
    private func configView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Music Player"
        listSongTable.register(UINib(nibName: "MusicInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "MusicInfoTableViewCell")
        listSongTable.delegate = self
        listSongTable.dataSource = self
    }
    
    private func initListSong() {
        listSong.append(Song(name: "Tong phu", performer: "Keyo", image: "image_0_song", audio: "TongPhuSong"))
        listSong.append(Song(name: "Biet tim dau", performer: "Tuan Hung", image: "image_1_song", audio: "BietTimDauSong"))
        listSong.append(Song(name: "Vo tan", performer: "Trinh Thang Binh", image: "image_2_song", audio: "VoTanSong"))
    }

}

extension ListSongViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSong.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicInfoTableViewCell", for: indexPath) as! MusicInfoTableViewCell
        cell.bindNameSong(listSong[indexPath.row].name)
        cell.bindPerformerSong(listSong[indexPath.row].performer)
        cell.bindImageSong(listSong[indexPath.row].image)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailSongViewController = storyboard.instantiateViewController(withIdentifier: "DetailSongViewController") as! DetailSongViewController
        detailSongViewController.bindListSong(listSong)
        detailSongViewController.bindIndexCurrentSong(indexPath.row) 
        self.navigationController?.pushViewController(detailSongViewController, animated: true)
    }
    
    
}
