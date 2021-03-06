//
//  FlickrAPI.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 8/25/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper

enum DataManagerError: Error {
    case unknown
    case failedRequest
    case invalidResponse
}

final class FlickrAPI {
    
    typealias PhotoDataCompletion = (FlickrPhoto?, DataManagerError?) -> ()
    
    // MARK: Properties
    
    let flickrAPIKey: String?
    
    init(withAPIKey flickrKey: String) {
        self.flickrAPIKey = flickrKey
    }
    
    /// Returns the URL for a HTTP call of the Flickr-API
    ///
    /// - Parameters:
    ///   - method: HTTP method of Flickr-API (e.g. "flickr.photos.search")
    ///   - api_key: generated API-KEY (stored in Constants)
    ///   - parameters: parameters for the HTTP call
    /// - Returns: url for API call
    private func api(method: String, api_key: String, parameters: String) -> String {
        return "\(API.FlickrAPIURL)?method=\(method)&api_key=\(api_key)&\(parameters)&format=json&nojsoncallback=1&page=1&accuracy=16&page=1"
        
    }
    
    /// Flickr-API-Call using the "flickr.photos.search" method, to retrieve an image based on location. If the call returns results, a random picture's image-url is returned
    ///
    /// - Parameters:
    ///   - lat: latitude of location
    ///   - lon: longitude of location
    ///   - completion: completion handler to retrieve result
    public func photoSearch(lat: String, lon: String, completion: @escaping PhotoDataCompletion) {
        
        let url = api(method: "flickr.photos.search", api_key: API.FlickrAPIKey, parameters: "lat=\(lat)&lon=\(lon)")
        
        // make a call to the "flickr.photos.search"-API to retrieve photos of given location
        Alamofire.request(url).responseObject { (response: DataResponse<FlickrPhotosResult>) in
            self.didFetchPhotoData(response: response, completion: completion)
        }
    }
    
    private func didFetchPhotoData(response: DataResponse<FlickrPhotosResult>, completion: PhotoDataCompletion) {
        switch response.result {
        case .success:
            
            if response.response?.statusCode == 200 {
                
                if let flickrPhotos = response.result.value, let photos = flickrPhotos.photos, let photosCount = photos.photos?.count {
                    if photosCount > 0 {
                        // return random photo of returned results
                        let number = Util.randomIntFrom(start: 0, to: (photos.photos?.count)! - 1)
                        
                        let photo = photos.photos?[number]
                        completion(photo, nil)
                    }
                }
                else {
                    completion(nil, .invalidResponse)
                }
                
            }
            else {
                completion(nil, .failedRequest)
            }
            
            break
        case .failure:
            completion(nil, .failedRequest)
            break
        }
    }
    
}
