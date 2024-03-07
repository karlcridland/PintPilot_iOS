//
//  LegalButton.swift
//  pint pilot
//
//  Created by Karl Cridland on 29/11/2020.
//

import Foundation
import UIKit

class LegalButton: UIButton{
    init(frame: CGRect, info: legalStruct){
        super .init(frame: frame)
        setTitle(info.title, for: .normal)
        setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
        contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 0)
        contentHorizontalAlignment = .left
        
        addLink(info.website)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
