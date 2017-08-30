//
//  FlickrAPI.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 8/25/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import Foundation
import Alamofire

class FlickrAPI {
    
    /// Returns the URL for a HTTP call of the Flickr-API
    ///
    /// - Parameters:
    ///   - method: HTTP method of Flickr-API (e.g. "flickr.photos.search")
    ///   - api_key: generated API-KEY (stored in Constants)
    ///   - parameters: parameters for the HTTP call
    /// - Returns: url for API call
    public class func api(method: String, api_key: String, parameters: String) -> String {
        return "\(Constants.FLICKR_API_URL)?method=\(method)&api_key=\(api_key)&\(parameters)&format=json&nojsoncallback=1&page=1&accuracy=16&page=1"
        
    }
    
    /// Return URL of image hosted on the Flickr-Severs
    ///
    /// - Parameters:
    ///   - farm_id: farm-id of photo
    ///   - server_id: server-id of photo
    ///   - photo_id: photo-id
    ///   - secret: secret of photo
    /// - Returns: URL of image
    public class func getPhoto(farm_id: String, server_id: String, photo_id: String, secret: String) -> String {
        return "https://farm\(farm_id).staticflickr.com/\(server_id)/\(photo_id)_\(secret).jpg"
    }
    
    /// Flickr-API-Call using the "flickr.photos.search" method, to retrieve an image based on location. If the call returns results, a random picture's image-url is returned
    ///
    /// - Parameters:
    ///   - lat: latitude of location
    ///   - lon: longitude of location
    ///   - completion: completion handler to retrieve result
    open class func photoSearch(lat: String, lon: String, completion: @escaping (_ success: Bool, _ imageURL: String) -> Void) {
        
        let url = FlickrAPI.api(method: "flickr.photos.search", api_key: Constants.FLICKR_API_KEY, parameters: "lat=\(lat)&lon=\(lon)")
        
        // make a call to the "flickr.photos.search"-API to retrieve photos of given location
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            
            switch response.result {
            case .success:
                
                if response.response?.statusCode == 200 {
                    
                    let result_dict = response.result.value as! NSDictionary
                    let photos_result = result_dict["photos"] as! NSDictionary
                    let photos = photos_result["photo"] as! NSArray
                    
                    if photos.count > 0 {
                        
                        // return random photo of returned results
                        let number = Util.randomIntFrom(start: 0, to: photos.count - 1)
                        
                        let photo = photos[number] as! NSDictionary
                        
                        let farm = photo["farm"] as! NSNumber
                        let server = photo["server"] as! String
                        let photo_id = photo["id"] as! String
                        let secret = photo["secret"] as! String
                        
                        completion(true, FlickrAPI.getPhoto(farm_id: farm.stringValue, server_id: server, photo_id: photo_id, secret: secret))
                    }
                    else {
                        completion(false, "No photos found")
                    }
                    
                }
                else {
                    completion(false, "Status code: \(response.response?.statusCode ?? -1)")
                }
                
                break
            case .failure:
                
                completion(false, "An unknown error occured. Please try again later.")
                break
            }
        }
    }
    
}
