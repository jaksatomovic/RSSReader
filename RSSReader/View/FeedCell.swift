//
//  FeedCell.swift
//  RSSReader
//
//  Created by Jakša Tomović on 02/02/2018.
//  Copyright © 2018 Jakša Tomović. All rights reserved.
//

import UIKit
import  Kingfisher

class FeedCell: UICollectionViewCell {
    
    
    var item: Item? {
        didSet {
            titleLabel.text = item?.title
            titleLabel.sizeToFit()
            titleLabel.numberOfLines = 0
            if let imageData = item?.image?.url {
                feedImageView.kf.setImage(with: URL(string: imageData))
            }
        }
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var feedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.tealColor
    }

}
