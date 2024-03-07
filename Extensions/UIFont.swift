//
//  UIFont.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

extension UIFont{
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic, .traitBold)
    }
}
