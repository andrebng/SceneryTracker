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
        
        let expct = expectation(description: "Returns photo")
        
        let lat = "47.572094"
        let lon = "10.166806"
        
        flickrAPI?.photoSearch(lat: lat, lon: lon, completion: { (success, photo, message) in
            XCTAssertTrue(success, message)
            expct.fulfill()
        })
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPhotoSearchInvalidLocation() {
        
        let expct = expectation(description: "Returns photo")
        
        let lat = "invalid"
        let lon = "invalid"
        
        flickrAPI?.photoSearch(lat: lat, lon: lon, completion: { (success, photo, message) in
            XCTAssertFalse(success, message)
            expct.fulfill()
        })
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPhotoImageURL() {
        
        let expct = expectation(description: "Returns all fields to create valid image url")
        
        let lat = "47.572094"
        let lon = "10.166806"
        
        flickrAPI?.photoSearch(lat: lat, lon: lon, completion: { (success, photo, message) in
            if success {
                
                if photo?.farm == nil {
                    XCTFail("No farm id returned")
                }
                
                if photo?.server == nil {
                    XCTFail("No server id returned")
                }
                
                if photo?.photoId == nil {
                    XCTFail("No photo id returned")
                }
                
                if photo?.secret == nil {
                    XCTFail("No secret id returned")
                }
                
                XCTAssert(true, "Success")
                expct.fulfill()
            }
            else {
                XCTFail(message)
            }
        })
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }
    
}
