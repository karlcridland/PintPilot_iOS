//
//  Settings.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit

class Settings {
    
    var home: ViewController?
    var upper_bound = CGFloat(0.0)
    var lower_bound = CGFloat(0.0)
    var keyboard_height: CGFloat?
    
    var venues = [Venue]()
    
    var venue: String?
    var table: String?
    
    var cards: [Card]?
    
    private let defaults = UserDefaults.standard
    
    public static let shared = Settings()
    
    private init(){}
    
    func banking(_ method: String){
        defaults.set(method, forKey: "banking_method")
    }
    
    func getBanking() -> String?{
        if let method = defaults.value(forKey: "banking_method") as? String{
            return method
        }
        return nil
    }
    
    func card(_ method: Int){
        defaults.set(method, forKey: "card_saved")
    }
    
    func getCard() -> Int?{
        if let method = defaults.value(forKey: "card_saved") as? Int{
            return method
        }
        return nil
    }
    
    func removeCard(_ card: Card){
        if cards != nil{
            cards!.removeAll(where: {$0 == card})
        }
    }
    
}
