//
//  FlickrAPITest.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 9/1/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import XCTest
@testable import SceneryTracker
import Alamofire

class FlickrAPITests: XCTestCase {
    
    var flickrAPI : FlickrAPI? = nil
    
    override func setUp() {
        super.setUp()
        
        flickrAPI = FlickrAPI(withAPIKey: API.FlickrAPIKey)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPhotoSearchReturnsPhoto() {
        
        let lat = "47.572094"
        let lon = "10.166806"
        
        flickrAPI?.photoSearch(lat: lat, lon: lon, completion: { (success, photo, message) in
            XCTAssert(true, message)
        })
    }
    
    func testPhotoImageURL() {
        let lat = "47.572094"
        let lon = "10.166806"
        
        flickrAPI?.photoSearch(lat: lat, lon: lon, completion: { (success, photo, message) in
            if success {
                
                if photo?.farm != nil {
                    XCTAssert(false, "No farm id returned")
                }
                
                if photo?.server != nil {
                    XCTAssert(false, "No server id returned")
                }
                
                if photo?.photoId != nil {
                    XCTAssert(false, "No photo id returned")
                }
                
                if photo?.secret != nil {
                    XCTAssert(false, "No secret id returned")
                }
                
                XCTAssert(true, "Success")
            }
            else {
                XCTAssert(false, message)
            }
        })
    }
    
}
