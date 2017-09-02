//
//  PhotoStream.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 8/25/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import Kingfisher

class PhotoStream: UIViewController {
    
    //MARK: Variables
    @IBOutlet var tableView         : UITableView!              // table representing photostream
    @IBOutlet var startStopButton   : UIBarButtonItem!          // starts location and distance tracking
    
    fileprivate var flickrAPI       : FlickrAPI?
    fileprivate var sceneryPhotos   : NSMutableArray = []       // array photos from the Flickr-API
    fileprivate var locationMngr    : LocationManager?          // For location tracking
    
    private var isStarted           : Bool = false              // var for switching start and stop button
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Distance: 0.00 m"
        
        // table view setup
        self.tableView.delegate         = self
        self.tableView.dataSource       = self
        self.tableView.separatorColor   = UIColor.clear
        
        // Initialize LocationManager Module
        locationMngr = LocationManager()
        locationMngr?.delegate = self
        locationMngr?.requestFlickrPhotos = true                // request photos after default setting of 100 m (requires implementation of delegate method *photoAfterLocationUpdate*
    }
    
    //MARK: Actions
    @IBAction func clickedStartStop(_ sender: Any) {
        
        self.isStarted = !self.isStarted
        
        if self.isStarted {
            
            locationMngr?.startUpdatingLocation()
            self.startStopButton.title = "STOP"
        }
        else {
            
            locationMngr?.stopUpdatingLocation()
            self.startStopButton.title = "START"
            self.title = "Distance: 0.00 m"
        }
    }
    
}

//MARK: LocationManager Module Delegate
extension PhotoStream: LocationModuleDelegate {
 
    func tracingLocation(currentLocation: CLLocation) {
        self.title = "Distance: \((self.locationMngr?.trimmedDistance())!)"
    }
    
    func photoAfterLocationUpdate(photo: FlickrPhoto) {
        
        puts("Add photo from Flickr")
        
        self.sceneryPhotos.insert(photo, at: 0)
        self.tableView.reloadData()
    }
    
    func tracingLocationDidFailWithError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorOccured(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension PhotoStream : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sceneryPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForImage(indexPath: indexPath)
    }
    
    // Private functions
    private func cellForImage(indexPath: IndexPath) -> UITableViewCell {
        
        var result = UITableViewCell()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageCell {
            
            let photo = sceneryPhotos[indexPath.row] as! FlickrPhoto
            
            // use of Kingfisher for async image loading
            let url = URL(string: photo.imageURL)
            cell.sceneryImage?.kf.setImage(with: url)
            
            result = cell
        }
        
        return result
    }
}
