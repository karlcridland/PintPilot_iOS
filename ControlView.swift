//
//  ControlView.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit

class ControlView: UIScrollView{
    
    private let logoPanel = UIView()
    private let logo = UIImageView()
    
    init() {
        super .init(frame: CGRect(x: 0, y: Settings.shared.upper_bound, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-(Settings.shared.upper_bound+Settings.shared.lower_bound+50)))
        backgroundColor = .systemGray5
        
        logoPanel.frame = CGRect(x: frame.width/2-40, y: 0, width: 80, height: 80)
        logo.frame = CGRect(x: 0, y: 0, width: logoPanel.frame.height, height: logoPanel.frame.height)
        logo.image = UIImage(named: "logo")
        logo.contentMode = .scaleAspectFit
        
        addSubview(logoPanel)
        logoPanel.addSubview([logo])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
