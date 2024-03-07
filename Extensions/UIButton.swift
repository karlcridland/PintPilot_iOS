//
//  UIButton.swift
//  pint pilot
//
//  Created by Karl Cridland on 29/11/2020.
//

import Foundation
import UIKit

extension UIButton{
    
    func addLink(_ link: String){
        self.addTarget(self, action: #selector(openLink), for: .touchUpInside)
        self.accessibilityLabel = link
    }
    
    @objc private func openLink(sender: UIButton){
        if let link = sender.accessibilityLabel{
            guard let url = URL(string: link) else { return }
            UIApplication.shared.open(url)
        }
    }
    
    func configure(color: UIColor = .blue, font: UIFont = UIFont.boldSystemFont(ofSize: 12)) {
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = font
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }

    func configure(icon: UIImage, color: UIColor? = nil) {
        self.setImage(icon, for: .normal)
        if let color = color {
            tintColor = color
        }
    }

    func configure(color: UIColor = .blue,
                   font: UIFont = UIFont.boldSystemFont(ofSize: 12),
                   cornerRadius: CGFloat,
                   borderColor: UIColor? = nil,
                   backgroundColor: UIColor,
                   borderWidth: CGFloat? = nil) {
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = font
        self.backgroundColor = backgroundColor
        if let borderColor = borderColor {
            self.layer.borderColor = borderColor.cgColor
        }
        if let borderWidth = borderWidth {
            self.layer.borderWidth = borderWidth
        }
        self.layer.cornerRadius = cornerRadius
    }
}
