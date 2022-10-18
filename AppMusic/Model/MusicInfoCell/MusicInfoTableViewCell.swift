//
//  MusicInfoTableViewCell.swift
//  AppMusic
//
//  Created by le.n.t.trung on 17/10/2022.
//

import UIKit

final class MusicInfoTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var performerSongLable: UILabel!
    @IBOutlet private weak var nameSongLabel: UILabel!
    @IBOutlet private weak var imageSongImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindData(_ song: Song) {
        imageSongImageView.image = UIImage(named: song.image)
        nameSongLabel.text = song.name
        performerSongLable.text = song.performer
    }
}
