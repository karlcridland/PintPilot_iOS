//
//  InputButton.swift
//  pint pilot
//
//  Created by Karl Cridland on 29/11/2020.
//

import Foundation
import UIKit

class InputButton: UIButton {
    
    var isChecked = false
    var range = [InputButton]()
    private var bubble = UIButton()
    private let color: UIColor
    
    init(frame: CGRect, value: String, color: UIColor) {
        self.color = color
        super .init(frame: frame)
        
        bubble = UIButton(frame: CGRect(x: 2, y: 2, width: frame.height-4, height: frame.height-4))
        bubble.layer.cornerRadius = bubble.frame.height/2
        bubble.layer.borderWidth = 2
        bubble.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        addSubview(bubble)
        
        setTitle(value, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
        contentEdgeInsets = UIEdgeInsets.init(top: 0, left: bubble.frame.height+14, bottom: 0, right: 0)
        
        contentHorizontalAlignment = .left
        
        addTarget(self, action: #selector(check), for: .touchUpInside)
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
        bubble.addTarget(target, action: action, for: controlEvents)
    }
    
    func access(_ str: String){
        accessibilityLabel = str
        bubble.accessibilityLabel = str
    }
    
    func t(_ i: Int){
        tag = i
        bubble.tag = i
    }
    
    @objc func check(){
        for button in range{
            if button == self{
                button.isChecked = true
            }
            else{
                button.isChecked = false
                button.display()
            }
        }
        isChecked = true
        display()
    }
    
    func display(){
        if isChecked{
            let inner = UIButton(frame: CGRect(x: 0, y: 0, width: frame.height-4, height: frame.height-4))
            inner.layer.cornerRadius = bubble.frame.height/2
            inner.backgroundColor = color
            inner.transform = CGAffineTransform(scaleX: 0.6, y: 0.6 )
            
            bubble.addSubview(inner)
        }
        else{
            bubble.removeAll()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

