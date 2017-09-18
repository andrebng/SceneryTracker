//
//  PhotoStreamViewViewModel.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 9/17/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import Foundation
import CoreLocation

class PhotoStreamViewViewModel {
    
    // MARK: - Properties
    
    var location: CLLocation = CLLocation(latitude: 0, longitude: 0) {
        didSet {
            searchForPhoto(location: location)
        }
    }
    
    // MARK: - 
    
    var numberOfPhotos: Int { return photos.count }
    
    // MARK: -
    
    var queryingDidChange:  ((Bool) -> ())?
    var didUpdatePhotos:    (([FlickrPhoto]) -> ())?
    
    // MARK: -
    
    private var mutablePhotos: NSMutableArray = NSMutableArray()
    
    // MARK: -
    
    private var photos: [FlickrPhoto] = [] {
        didSet {
            didUpdatePhotos?(photos)
        }
    }
    
    private var querying: Bool = false {
        didSet {
            queryingDidChange?(querying)
        }
    }
    
    private lazy var flickrAPI = FlickrAPI(withAPIKey: API.FlickrAPIKey)
    
    // MARK: Public Interface
    
    func photo(at index: Int) -> FlickrPhoto? {
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func viewModelForPhoto(at index: Int) -> FlickrPhotoViewModel? {
        guard let photo = self.photo(at: index) else { return nil }
        return FlickrPhotoViewModel(photo: photo)
    }
    
    // MARK: - Helper Methods
    
    private func searchForPhoto(location: CLLocation?) {
        guard let location = location else {
            return
        }
        
        querying = true
        
        let lat = String(location.coordinate.latitude)
        let lon = String(location.coordinate.longitude)
        
        flickrAPI.photoSearch(lat: lat, lon: lon) { [weak self] (photo, error) in
            guard let _photo = photo else {
                self?.photos = []
                self?.mutablePhotos.removeAllObjects()
                return
            }
            
            self?.querying = false
            
            if let error = error {
                print("Unable to forward photo (\(error))")
            }
            else {
                self?.mutablePhotos.insert(_photo, at: 0)
                self?.photos = self?.mutablePhotos as! [FlickrPhoto]
            }
        }
    }
}
