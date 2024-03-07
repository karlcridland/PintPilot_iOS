//
//  PagePayment.swift
//  pint pilot
//
//  Created by Karl Cridland on 27/11/2020.
//

import Foundation
import UIKit
import SwiftGifOrigin

class PagePayment: Page{
    
    var processing = false
    var touchy: UIView?
    
    init() {
        super .init(title: "\(Settings.shared.venues.first(where: {$0.uid == Settings.shared.venue!})!.name!): Payment")
        
        if let home = Settings.shared.home{
            
            let productImageView = UIImageView(frame: CGRect(x: frame.width/2-50, y: 100, width: 100, height: 100))
            productImageView.image = UIImage(named: "logo")
            
            let logoAnimated = UIImageView()
            logoAnimated.loadGif(name: "logo_animated")
            logoAnimated.frame = productImageView.frame
            view.addSubview(logoAnimated)
            
            touchy = home.paymentTextField
            
            addSubview([productImageView,home.createPayment(Basket.shared.getTotal(),logoAnimated),logoAnimated])
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func moving(_ gesture: UIPanGestureRecognizer) {
        if let _ = touchy{
            becomeFirstResponder()
        }
        if !processing{
            super.moving(gesture)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
