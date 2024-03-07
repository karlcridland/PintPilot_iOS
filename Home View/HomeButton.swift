//
//  HomeButton.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit

class HomeButton: UIButton {
    
    var isReady = false
    
    init(frame: CGRect, title: String) {
        super .init(frame: frame)
        
        setTitle(title, for: .normal)
        setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        
        backgroundColor = .systemGray6
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        layer.cornerRadius = 10
        
    }
    
    func ready(){
        alpha = 1
        setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        isReady = true
    }
    
    func unready(){
        alpha = 0.6
        setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        isReady = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
