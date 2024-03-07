//
//  Card.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation

struct Card{
    let number: Int
    let exp_month: Int
    let exp_year: Int
    let security: Int
    
    static func == (left: Card, right: Card) -> Bool {
        return left.number == right.number && left.exp_month == right.exp_month && left.exp_year == right.exp_year && left.security == right.security
    }
    
    static func != (left: Card, right: Card) -> Bool {
        return !(left == right)
    }
    
}
