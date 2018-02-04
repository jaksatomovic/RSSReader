//
//  ListCell.swift
//  RSSReader
//
//  Created by Jakša Tomović on 02/02/2018.
//  Copyright © 2018 Jakša Tomović. All rights reserved.
//

import UIKit
import Kingfisher

class ListCell: UITableViewCell {
    
    var item: Channel? {
        didSet {
            titleLabel.text = item?.title

            if let imageData = item?.image?.url {
                feedImageView.kf.setImage(with: URL(string: imageData))
            }
        }
    }
    
    // you cannot declare another image view using "imageView"
    let feedImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.darkBlue.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "COMPANY NAME"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.tealColor
        
        addSubview(feedImageView)
        feedImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        feedImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        feedImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        feedImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: feedImageView.rightAnchor, constant: 8).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

