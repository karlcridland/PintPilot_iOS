//
//  Venue.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit
import CoreLocation

class Venue {
    
    let uid: String
    let location: CLLocationCoordinate2D
    var name: String?
    var tables: [String]?
    var dist: Int?
    
    init (_ uid: String, _ location: CLLocationCoordinate2D){
        self.uid = uid
        self.location = location
    }
    
    func distance(_ location: CLLocationCoordinate2D) {
        dist = Int(self.location.getDistance(location)*10)
    }
    
}
