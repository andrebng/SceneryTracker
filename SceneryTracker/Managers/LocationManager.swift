//
//  LocationManager.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 9/1/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import CoreLocation

@objc protocol LocationModuleDelegate {
    
    /// Catch error
    ///
    /// - Parameter message: error message
    func errorOccured(withMessage message: String)
    
    /// The updated location-update method
    ///
    /// - Parameter currentLocation: the current location
    func tracingLocation(currentLocation: CLLocation)
    
    /// Error handling when location update fails
    ///
    /// - Parameter error: the returned error
    func tracingLocationDidFailWithError(error: Error)
    
    /// Retrieves a photo via the Flickr-API based on the current location. Method implementation is required when setting *requestFlickrPhotos* to true
    ///
    /// - Parameter photo: the returned photo via the Flickr-API
    @objc optional func photoAfterLocationUpdate(photo: FlickrPhoto, location: CLLocation)
    
}

class LocationManager : NSObject {
    
    //MARK: Vars
    var delegate: LocationModuleDelegate?
    
    var currentLocation                     : CLLocation?           // holds current location
    var distanceTraveled                    : Double = 0.0          // holds current distance traveled
    var requestFlickrPhotos                 : Bool = false          // rather photo from Flickr should be requested after update
    var requestedPhotoDistance              : Double = 100.0        // request a photo every X meters; default 100m
    
    fileprivate var flickrAPI               : FlickrAPI?            // FlickrAPI
    fileprivate var locationManager         : CLLocationManager?
    fileprivate var startLocation           : CLLocation?           // first updated location
    fileprivate var lastLocation            : CLLocation?           // last updated location
    fileprivate var tmpDistanceTraveled     : Double = 0.0          // distance from previous location update
    fileprivate var requestPhoto            : Bool = false          // indicator when photo can be requested
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.distanceFilter = 10                            // updates every 100m
            self.locationManager?.allowsBackgroundLocationUpdates = true         // allow background location updates
            
            // Initialize FlickrAPI
            flickrAPI = FlickrAPI(withAPIKey: API.FlickrAPIKey)
        }
        else {
            
            guard let delegate = self.delegate else {
                return
            }
            
            delegate.errorOccured(withMessage: "Please enable the location services")
        }
    }
    
    //MARK: Public functions
    
    /// Start location tracking
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    /// Stop location tracking
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    /// Set the distance filter when updates occur. By default every 100 m
    ///
    /// - Parameter distance: distance in km
    func setDistanceFilter(inKm distance: Int) {
        self.locationManager?.distanceFilter = CLLocationDistance(distance)
    }
    
    /// Return trimmed tracked distance in meters
    ///
    /// - Returns: string of distance
    func trimmedDistance() -> String {
        return String(format: "%.2f", distanceTraveled)
    }
}

//MARK: CLLocationManagerDelegate
extension LocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last(current) location
        self.currentLocation = location
        
        // use for real time update location
        updateLocation(currentLocation: location, locations: locations)
        
        // use to get image of flickr
        if requestFlickrPhotos {
            getImageAfterUpdate()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationDidFailWithError(error: error)
    }
    
    //MARK: Private functions
    
    /// Calls the FlickrAPI after every *requestedPhotoDistance* meters and resets the *requestPhoto* flag
    private func getImageAfterUpdate() {
        
        guard let delegate = self.delegate else {
            return
        }
        
        guard let lastLocation = self.lastLocation else {
            return
        }
        
        if requestPhoto {
            
            requestPhoto = false
            
            let lat = String(lastLocation.coordinate.latitude)
            let lon = String(lastLocation.coordinate.longitude)
            
            flickrAPI?.photoSearch(lat: lat, lon: lon, completion: { (photo, error) in
                if !(error != nil) {
                    
                    guard let photo = photo else {
                        return
                    }
                    
                    delegate.photoAfterLocationUpdate!(photo: photo, location: lastLocation)
                }
                else {
                    delegate.errorOccured(withMessage: "An error occured retrieving the image.")
                }
            })
        }
        
    }
    
    /// Custom update location with added distance tracking
    ///
    /// - Parameters:
    ///   - currentLocation: the current location
    ///   - locations: previous locations as array
    private func updateLocation(currentLocation: CLLocation, locations: [CLLocation]){
        
        guard let delegate = self.delegate else {
            return
        }
        
        // Track distance
        if startLocation == nil {
            startLocation = locations.first as CLLocation!
        } else {
         
            guard let lastLocation = self.lastLocation else {
                return
            }
            
            let lastDistance = lastLocation.distance(from: locations.last as CLLocation!)
            distanceTraveled += lastDistance
            
            tmpDistanceTraveled += lastDistance
            
            if tmpDistanceTraveled >= requestedPhotoDistance && !requestPhoto {
                tmpDistanceTraveled = 0
                requestPhoto = true
            }
        }
        
        self.lastLocation = locations.last as CLLocation!
        
        delegate.tracingLocation(currentLocation: currentLocation)
    }
    
    /// Custom error handling of failed location update
    ///
    /// - Parameter error: occurred error of failure
    private func updateLocationDidFailWithError(error: Error) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error: error)
    }
}
