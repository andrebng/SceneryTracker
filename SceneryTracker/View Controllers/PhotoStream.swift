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
import SwiftOverlays

class PhotoStream: UIViewController {
    
    //MARK: Variables
    @IBOutlet var tableView         : UITableView!              // table representing photostream
    @IBOutlet var startStopButton   : UIBarButtonItem!          // starts location and distance tracking
    
    fileprivate var sceneryPhotos   : NSMutableArray = []       // array photos from the Flickr-API
    fileprivate var locationMngr    : LocationManager?          // For location tracking
    fileprivate var viewModel       : PhotoStreamViewViewModel! // View Model of Photo Stream
    
    private var isStarted           : Bool = false              // var for switching start and stop button
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Distance: 0.00 m"
        
        viewModel = PhotoStreamViewViewModel()
        
        viewModel.didUpdatePhotos = { [unowned self] (photos) in
            self.tableView.reloadData()
        }
        
        viewModel.queryingDidChange = { [unowned self] (querying) in
            if querying {
                self.showWaitOverlayWithText("Loading images...")
            }
            else {
                self.removeAllOverlays()
            }
        }
        
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
        
        guard let trimmedDistance = self.locationMngr?.trimmedDistance() else {
            return
        }
        
        self.title = "Distance: \(trimmedDistance)"
    }
    
    func photoAfterLocationUpdate(photo: FlickrPhoto, location: CLLocation) {
        
        puts("Add photo from Flickr")
        self.viewModel.location = location
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
        return self.viewModel.numberOfPhotos
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForImage(indexPath: indexPath)
    }
    
    // Private functions
    private func cellForImage(indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
            fatalError("Unexpected Table View Cell")
        }
        
        if let viewModel = viewModel.viewModelForPhoto(at: indexPath.row) {
            cell.configure(withViewModel: viewModel)
        }
        
        return cell
    }
}
