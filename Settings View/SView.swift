//
//  SView.swift
//  pint pilot
//
//  Created by Karl Cridland on 29/11/2020.
//

import Foundation
import UIKit

class SView: UIView{
    
    private let t = UILabel()
    
    init(title: String) {
        super .init(frame: .zero)
        t.text = title.uppercased()
        t.textAlignment = .center
        t.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        t.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.init(0.6))
        addSubview(t)
    }
    
    func update(){
        t.frame = CGRect(x: 0, y: 0, width: frame.width, height: 30)
        if let s = superview{
            t.frame = CGRect(x: 0, y: 0, width: s.frame.width, height: 30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
