//
//  CLLocationCoordinate2D.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D{
    
    func getDistance(_ coordinate: CLLocationCoordinate2D) -> Double{
        let R = 6371000
        
        let latx = coordinate.latitude * .pi / 180
        let laty = self.latitude * .pi / 180
        let latDif = (self.latitude - coordinate.latitude) * .pi / 180
        let lonDif = (self.longitude - coordinate.longitude) * .pi / 180
        let a = sin(latDif/2) * sin(latDif/2) + cos(latx) * cos(laty) * sin(lonDif/2) * sin(lonDif/2)
        let c = Double(2) * atan2(a.squareRoot(), (1-a).squareRoot())
        let d = (Double(R) * c)/1000 // kilometers
        return Double(round(10*d)/10)
    }
    
}
