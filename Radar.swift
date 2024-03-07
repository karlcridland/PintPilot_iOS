//
//  Radar.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit

class Radar: UIView {
    
    var timer: Timer?
    
    init() {
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/4))
        backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        clipsToBounds = true
        
        let color = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        
        for i in -2 ..< 5{
            let length = frame.width-((frame.width/8)*CGFloat(i)*2)
            
            let circle = UIView(frame: CGRect(x: 0, y: 0, width: length, height: length))
            circle.center = CGPoint(x: frame.width/2, y: frame.height)
            circle.layer.borderWidth = 2
            circle.layer.borderColor = color.cgColor
            circle.layer.cornerRadius = length/2
            addSubview(circle)
            
            let line = UIView(frame: CGRect(x: (frame.width/2)-1, y: frame.height-(frame.width), width: 2, height: frame.width*2))
            line.backgroundColor = color
            line.transform = CGAffineTransform(rotationAngle: (CGFloat.pi/6)*CGFloat(i))
            addSubview(line)
        }
        
        let whoosh = UIView(frame: CGRect(x: (frame.width/2)-10, y: frame.height-(frame.width)+10, width: 20, height: frame.width*2))
        
        for i in 0 ..< Int(whoosh.frame.width){
            let bar = UIView(frame: CGRect(x: whoosh.frame.width/2-CGFloat(i), y: 0, width: 1, height: whoosh.frame.height/2))
            let alpha = CGFloat(1) - CGFloat(i)/whoosh.frame.width
            bar.backgroundColor = color.withAlphaComponent(alpha)
            whoosh.addSubview(bar)
        }
        
        whoosh.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        
        addSubview(whoosh)
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { timer in
            self.timer = timer
            whoosh.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            UIView.animate(withDuration: 1, animations: {
                whoosh.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2-0.01)
            })
        })
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
