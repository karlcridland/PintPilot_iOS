//
//  BoardingPass.swift
//  pint pilot
//
//  Created by Karl Cridland on 26/11/2020.
//

import Foundation
import UIKit

class BoardingPass: UIView {
    
    let uid: String
    let id: String
    let table: String
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    
    var isDelivered = false
    var isSelected = false
    
    var title = [Int: String]()
    var extra = [Int: String]()
    var price = [Int: Int]()
    var quantity = [Int: Int]()
    var menu = [Int: String]()
    var submenu = [Int: String]()
    
    var qr = UIImageView()
    static var qr_codes = [String:UIImageView]()
    
    let button = UIButton()
    
    init(_ uid: String, _ id: String, _ table: String) {
        self.uid = uid
        self.id = id
        self.table = table
        super .init(frame: .zero)
    }
    
    func getTotal() -> Int{
        var total = 0
        for key in title.keys{
            if let p = price[key]{
                if let q = quantity[key]{
                    total += p*q
                }
            }
        }
        return total
    }
    
    func display(frame: CGRect, view: BoardingPassView){
        self.frame = frame
        removeAll()
        if let color = primaryColor{
            backgroundColor = color
        }
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        layer.cornerRadius = 10
        
        var labels = [UILabel]()
        
        if let name = view.venue_title[uid]{
            let title = UILabel(frame: CGRect(x: 10, y: 0, width: 3*frame.width/5-10, height: 50))
            labels.append(title)
            title.text = name
            addSubview(title)
        }
        
        let date = id.split(separator: ":")
        
        let time = UILabel(frame: CGRect(x: 3*frame.width/5, y: 0, width: 2*frame.width/5-10, height: 50))
        time.textAlignment = .right
        labels.append(time)
        time.text = "\(date[2])/\(date[1])/\(date[0])\n\(String(date[3]).setw("0", 2)):\(String(date[4]).setw("0", 2))"
        
        let prc = UILabel(frame: CGRect(x: frame.width/2, y: 50, width: frame.width/2-10, height: 100))
        prc.textAlignment = .left
        labels.append(prc)
        var text = "awaiting departure"
        if isDelivered{
            text = "arrived"
        }
        prc.text = "\(text)\ntable: \(table)\ntotal: \(getTotal().price(currency: .GBP))"
        
        for label in labels{
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(0.3))
            label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        button.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        addSubview([button,time,prc])
        
        button.addTarget(self, action: #selector(displayPass), for: .touchUpInside)
        
        let myUid = "k"
        
        let code = "\(uid)/\(myUid)/\(id)"
        
        qr = UIImageView(frame: CGRect(x: 20, y: 70, width: frame.height-90, height: frame.height-90))
        
        if let image = BoardingPass.qr_codes[code]?.image{
            qr.image = image
        }
        else{
            qr = QRGenerator(code: code, foreground: UIColor.white.cgColor, background: UIColor.black.cgColor)
            qr.frame = CGRect(x: 20, y: 70, width: frame.height-90, height: frame.height-90)
        }
        
        addSubview(qr)
        sendSubviewToBack(qr)
    }
    
    @objc func displayPass(){
        if let s = superview as? SpecView{
            s.focus(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

