//
//  Util.swift
//  SceneryTracker
//
//  Created by Andre Nguyen on 8/26/17.
//  Copyright © 2017 SceneryTracker. All rights reserved.
//

import Foundation

class Util {
    
    /// Return random number between 2 given numbers
    ///
    /// - Parameters:
    ///   - start: min value of number
    ///   - end: max value of number
    /// - Returns: random number between start and end number
    static func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
}
