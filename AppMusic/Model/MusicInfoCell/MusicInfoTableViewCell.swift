//
//  MusicInfoTableViewCell.swift
//  AppMusic
//
//  Created by le.n.t.trung on 17/10/2022.
//

import UIKit

class MusicInfoTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var performerSong: UILabel!
    @IBOutlet private weak var nameSong: UILabel!
    @IBOutlet private weak var imageSong: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindImageSong(_ image: String) {
        imageSong.image = UIImage(named: image)
    }
    
    func bindNameSong(_ name: String) {
        nameSong.text = name
    }
    
    func bindPerformerSong(_ performer: String) {
        performerSong.text = performer
    }
    
}
