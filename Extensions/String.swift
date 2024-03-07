//
//  String.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

extension String{
    
    func yesterday() -> String{
        let split = self.split(separator: ":")
        var yesterday = "\(split[0]):\(split[1]):\(Int(split[2])!-1)"
        if Int(split[2])! == 1{
            yesterday = "\(split[0]):\(Int(split[1])!-1):\(Int(split[1])!.monthCountFromYear(Int(split[0])!))"
            if Int(split[1])! == 1{
                yesterday = "\(Int(split[0])!-1):12:31"
            }
        }
        return yesterday
    }
    
    func toDate() -> String {
        let split = self.split(separator: ":")
        if split.count >= 3{
            return "\(split[2]) / \(split[1]) / \(split[0])"
        }
        return ""
    }
    
    func setw(_ character: Character, _ width: Int) -> String{
        var new = self
        while new.count < width{
            new = String(character)+new
        }
        return new
    }
    
    func CGWordWidth(font_size: CGFloat) -> CGFloat{
        var length = CGFloat(0)
        for character in self{
            length += String(character).CGWidth(font_size: font_size)
        }
        return length
    }
    
    func CGWidth(font_size: CGFloat) -> CGFloat {
        var tester = " "
        if self == " "{
            tester = "a"
        }
        let prefix = (self as NSString).substring(to: (self+tester).range(of: tester)!.lowerBound.utf16Offset(in: self)) as NSString
        let size = prefix.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font_size)])
        return size.width
    }
    
    func blurCard() -> String {
        var str = ""
        var i = 0
        for c in self{
            if i < 12{
                str += "*"
            }
            else{
                str += String(c)
            }
            
            if i%4 == 3{
                str += " "
            }
            i += 1
        }
        return str
    }
    
    func hours() -> Int{
        return Int(self.split(separator: ":")[0])!
    }
    func minutes() -> Int{
        return Int(self.split(separator: ":")[1])!
    }
    
    func cardSpacing() -> String{
        var str = ""
        
        var i = 0
        for n in self.replacingOccurrences(of: " ", with: ""){
            if n.isNumber{
                str += String(n)
                
                if i%4 == 3{
                    str += " "
                }
                
                i += 1
            }
        }
        
        while str.count > 19 {
            str.removeLast()
        }
        
        return str
    }
    
    func expiry_validation(_ previous: String?) -> String{
        var str = ""
        
        var i = 0
        for n in self.replacingOccurrences(of: "/", with: ""){
            if n.isNumber{
                str += String(n)
                
                if i%3 == 1{
                    str += " / "
                }
                
                i += 1
            }
        }
        
        while str.count > 7 {
            str.removeLast()
        }
        
        return str
    }
    
    func cvc_validation() -> String{
        var str = ""
        
        for n in self{
            if n.isNumber{
                str += String(n)
            }
        }
        
        while str.count > 3 {
            str.removeLast()
        }
        
        return str
    }
    
    func isPassword() -> Bool{
        return self.contains(where: {String($0).isInt}) && self.contains(where: {$0.isLetter && $0.isUppercase}) && self.contains(where: {$0.isLetter && $0.isLowercase}) && self.count > 8
    }
    
    func isEmail() -> Bool{
        let split = self.split(separator: "@")
        if split.count != 2{
            return false
        }
        return split[1].split(separator: ".").count > 1
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var isLetter: Bool{
        let letters = NSCharacterSet.letters

        let range = self.rangeOfCharacter(from: letters)

        // range will be nil if no letters is found
        if let _ = range {
            return true
        }
        else{
            return false
        }
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}
