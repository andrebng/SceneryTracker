//
//  ImageCell.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 8/25/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet var sceneryImage: UIImageView!
    
    override func layoutSubviews() {
        self.cardSetup()
    }
    
    func cardSetup() {
        
    }
}
