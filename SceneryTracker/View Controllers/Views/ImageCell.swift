//
//  ImageCell.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 8/25/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//
import UIKit
import Kingfisher

class ImageCell: UITableViewCell {
    
    // MARK: - Type Properties
    
    static let reuseIdentifier = "ImageCell"
    
    // MARK: - Properties
    
    @IBOutlet var sceneryImage: UIImageView!
    
    // MARK: - Configuration
    
    func configure(withViewModel viewModel: FlickrPhotoViewModel) {
        sceneryImage.kf.setImage(with: viewModel.imageURL)
    }
}
