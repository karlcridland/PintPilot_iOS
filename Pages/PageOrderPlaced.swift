//
//  PageOrderPlaced.swift
//  pint pilot
//
//  Created by Karl Cridland on 26/11/2020.
//

import Foundation
import UIKit

class PageOrderPlaced: Page{
    
    init() {
        super .init(title: "Order Placed")
        Firebase.shared.placeOrder()
        Basket.shared.empty()
        
        if let bv = Control.shared.boardingView{
            Firebase.shared.getBoardingPasses(bv)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


