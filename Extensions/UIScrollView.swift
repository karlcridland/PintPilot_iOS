//
//  UIScrollView.swift
//  pint pilot
//
//  Created by Karl Cridland on 03/12/2020.
//

import Foundation
import UIKit

extension UIScrollView{
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
    
}
