//
//  Opening_Hours.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation

struct Opening_Hours{
    let monday: Open_Close
    let tuesday: Open_Close
    let wednesday: Open_Close
    let thursday: Open_Close
    let friday: Open_Close
    let saturday: Open_Close
    let sunday: Open_Close
}

struct Open_Close {
    let open: String
    let close: String
}
