//
//  QRGenerator.swift
//  pint pilot
//
//  Created by Karl Cridland on 29/11/2020.
//

import Foundation
import UIKit

class QRGenerator: UIImageView{
    
    let code: String
    
    init(code: String, foreground: CGColor, background: CGColor){
        
        self.code = code
        
        // Initialises with a choice of color for the qr code.
        
        super .init(frame: CGRect(x: 0, y: Settings.shared.upper_bound, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        image = construct(code: code, foreground: foreground, background: background)
        
    }
    
    func construct(code: String, foreground: CGColor, background: CGColor) -> UIImage?{
        
        backgroundColor = UIColor(cgColor: background)
        
        transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        // Creates the qr code and converts it into a uiimage.
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(code.data(using: String.Encoding.ascii), forKey: "inputMessage")

            if let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 20, y: 20)) {
                
                return UIImage(ciImage: output).maskWithColor(foreground, output)
                
            }
        }
        
        return nil
    }
    
    func share() -> UIImage{
        
        frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        image = construct(code: code, foreground: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), background: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ScanExample: UIView{
    
    var moved = true
    let phone: UIImageView
    
    override init(frame: CGRect){
        phone = UIImageView(frame: CGRect(x: 0, y: -45, width: frame.width, height: frame.height))
        super .init(frame: frame)
        
        let qr = UIImageView(frame: CGRect(x: 0, y: -20, width: frame.width, height: frame.height))
        qr.image = UIImage(named: "qrExample")
        phone.image = UIImage(named: "phoneScan")
        
        addSubview([qr,phone])
        
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { timer in
            self.moved = !self.moved
            UIView.animate(withDuration: 1, animations: {
                if self.moved{
                    self.phone.frame = CGRect(x: 0, y: -45, width: self.frame.width, height: self.frame.height)
                }
                else{
                    self.phone.frame = CGRect(x: 0, y: 10, width: self.frame.width, height: self.frame.height)
                }
            })
        })
        
        qr.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        alpha = 0.6
        
        layer.cornerRadius = 10
        layer.borderWidth = 1.5
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

