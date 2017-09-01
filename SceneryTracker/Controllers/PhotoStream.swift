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
    private var isStarted           = false                     // var for switching start and stop button
    fileprivate var sceneryPhotos   : NSMutableArray = []       // array photos from the Flickr-API
    
    // For location tracking
    private var locationManager         : CLLocationManager?    // location manager
    fileprivate var startLocation       : CLLocation!           // first updated location
    fileprivate var lastLocation        : CLLocation!           // last updated location
    var distanceTraveled                = 0.0                   // current distance traveled
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Distance: 0.00 m"
        
        // table view setup
        self.tableView.delegate         = self
        self.tableView.dataSource       = self
        self.tableView.separatorColor   = UIColor.clear
        
        // Initialize FlickrAPI
        flickrAPI = FlickrAPI(withAPIKey: API.FlickrAPIKey)
        
        // Init and setup of location services
        locationSetup()
    }
    
    /// Sets up the location manager
    private func locationSetup() {
        
        self.locationManager = CLLocationManager()
        self.locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.distanceFilter = 100                           // updates every 100m
            self.locationManager?.allowsBackgroundLocationUpdates = true         // allow background location updates
        } else {
            let alert = UIAlertController(title: "Error", message: "Please enable the location services", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //MARK: Actions
    @IBAction func clickedStartStop(_ sender: Any) {
        
        self.isStarted = !self.isStarted
        
        if self.isStarted {
            
            distanceTraveled = 0.0
            startLocation = nil
            lastLocation = nil
            
            locationManager?.startUpdatingLocation()
            self.startStopButton.title = "STOP"
        }
        else {
            
            locationManager?.stopUpdatingLocation()
            self.startStopButton.title = "START"
            self.title = "Distance: 0.00 m"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


//MARK: CLLocationManagerDelegate
extension PhotoStream: CLLocationManagerDelegate {
    
    // updated every 100m based on distance-filter
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first as CLLocation!
        } else {
            let lastDistance = lastLocation.distance(from: locations.last as CLLocation!)
            distanceTraveled += lastDistance
            
            if distanceTraveled >= 100 {
                
                let lat = String(lastLocation.coordinate.latitude)
                let lon = String(lastLocation.coordinate.longitude)
                
                flickrAPI?.photoSearch(lat: lat, lon: lon, completion: { (success, result, message) in
                    if success {
                        
                        // result = imageResult if api returned successfully
                        self.sceneryPhotos.insert(result!, at: 0)                // insert new image on on top
                        self.tableView.reloadData()
                        
                    }
                    else {
                        let alert = UIAlertController(title: "Error", message: "An error occured retrieving the image. \(message)", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                
            }
            
            let trimmedDistance = String(format: "%.2f", distanceTraveled)
            
            self.title = "Distance: \(trimmedDistance) m"
        }
        
        lastLocation = locations.last as CLLocation!
        
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
    
    private func cellForImage(indexPath: IndexPath) -> UITableViewCell {
        
        var result = UITableViewCell()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageCell {
            
            let photo = sceneryPhotos[indexPath.row] as! FlickrPhoto
            
            puts("Photo: \(photo.imageURL as String?)")
            
            // use of Kingfisher for async image loading
            let url = URL(string: photo.imageURL)
            cell.sceneryImage?.kf.setImage(with: url)
            
            result = cell
        }
        
        return result
    }
}
