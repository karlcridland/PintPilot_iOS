//
//  Int.swift
//  pint pilot
//
//  Created by Karl Cridland on 27/11/2020.
//

import Foundation

extension Int{
    
    func ordinate() -> String{
        if (self%100 >= 11) && (self%100 <= 13){
            return String(self)+"th"
        }
        else{
            switch self%10 {
            case 1:
                return String(self)+"st"
            case 2:
                return String(self)+"nd"
            case 3:
                return String(self)+"rd"
            default:
                return String(self)+"th"
            }
        }
    }
    
    func isLeapYear() -> Bool{
        if self % 4 == 0 {
            if self % 100 == 0 && self % 400 != 0 {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func monthCountFromYear(_ year: Int) -> Int{
        print(self,year)
        if year.isLeapYear() && self == 3{
            return 29
        }
        let m = [31,28,31,30,31,30,31,31,30,31,30,31]
        return m[self-2]
    }
    
    func shorten() -> String{
        var extra = 0
        if (self/2 < 10 && self%2 == 1){
            extra = 1
        }
        
        func decimal(_ i: Int) -> String{
            let main = i/10
            let dec = i%10
            return "\(main+extra).\(dec)"
        }
        
        let cs = ["k","m","b","tr"]
        var i = cs.count-1
        for _ in cs{
            if (self/2) > pow(1000, i+1).toInt()-1{
                return "\(decimal((self/2)/(pow(1000, i+1).toInt()/10)))\(cs[i])"
            }
            i -= 1
        }
        return String(self/2)
    }
    
    func price(currency: Currency) -> String{
        var pence = String(self%100)
        while pence.count < 2{
            pence = "0"+pence
        }
        let pounds = String(self/100)
        switch currency{
            case .HRK:
                return "\(pounds),\(pence) \(currency.rawValue)"
            case .EUR:
                return "\(pounds),\(pence) \(currency.rawValue)"
            case .HUF:
                return "\(pounds)\(pence) \(currency.rawValue)"
            default:
                return "\(currency.rawValue)\(pounds).\(pence)"
        }
    }
    
}


enum Currency: String{
    case GBP = "£"
    case USD = "$"
    case CNY = "¥"
    case HRK = "kn"
    case EGP = "EGP"
    case EUR = "€"
    case HGK = "HK$"
    case HUF = "Ft"
}
