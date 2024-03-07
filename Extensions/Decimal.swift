//
//  Decimal.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation

extension Decimal{
    
    func toInt() -> Int{
        let result = NSDecimalNumber(decimal: self)
        return Int(truncating: result)
    }
}
