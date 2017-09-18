//
//  FlickrPhotoModelView.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 8/31/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import Foundation

struct FlickrPhotoViewModel {
    
    let photo : FlickrPhoto
    
    // MARK: -
    
    var farm: String {
        return photo.farm.stringValue
    }
    
    var server: String {
        return photo.server
    }
    
    var photoId: String {
        return photo.photoId
    }
    
    var secret: String {
        return photo.secret
    }
    
    var imageURL: URL? {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret).jpg")
    }
}
