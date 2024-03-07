//
//  PageBoardingPass.swift
//  pint pilot
//
//  Created by Karl Cridland on 26/11/2020.
//

import Foundation
import UIKit

class PageBoardingPass: Page{
    
    let info = UIView(frame: CGRect(x: 0, y: Settings.shared.upper_bound, width: UIScreen.main.bounds.width, height: 150))
    let block = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Settings.shared.upper_bound))
    
    init(pass: BoardingPass) {
        super .init(title: "Boarding Pass")
        
        self.backgroundColor = pass.backgroundColor
        
        let qr = UIImageView(frame: CGRect(x: 20, y: 20, width: 110, height: 110))
        qr.image = pass.qr.image
        block.backgroundColor = .systemGray5
        
        let title = UILabel(frame: CGRect(x: 150, y: 0, width: info.frame.width-150, height: info.frame.height))
        title.numberOfLines = 0
        title.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        
        if let boardingView = Control.shared.boardingView{
            if let t = boardingView.venue_title[pass.uid]{
                title.text = "\(t)\n\nTable: \(pass.table)\n\nTotal: \(pass.getTotal().price(currency: .GBP))"
            }
        }
        
        if let color = pass.secondaryColor{
            title.textColor = color
        }
        else{
            title.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        info.addSubview([qr,title])
        addSubview([block,info])
        
        var i = 0
        let height = CGFloat(100)
        
        for key in pass.title.keys{
//            print(pass.id)
//            print(pass.title)
            let title = pass.title[key]!
            let price = pass.price[key]!
            let size = pass.extra[key]
            let menu = pass.menu[key]!
            let subMenu = pass.submenu[key]!
            
            let menuItem = MenuItem(frame: .zero, item: title, size: size, price: price, cat: menu, subCat: subMenu)
            
            let push = BasketPush(frame: CGRect(x: 0, y: CGFloat(i)*(height+20)+height, width: view.frame.width, height: height), menuItem: menuItem, review: true)
            push.quantity = pass.quantity[key]!
            push.updatePrice(UIButton())
            push.review_item()
            push.backgroundColor = .clear
            push.layer.borderWidth = 0
            
            for subview in push.subviews{
                if subview is UIButton{
                    subview.removeFromSuperview()
                }
                if let label = subview as? UILabel{
                    if let color = pass.secondaryColor{
                        label.textColor = color
                    }
                    else{
                        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    }
                }
            }
            
            view.addSubview(push)
            i += 1
            
            view.frame = CGRect(x: 0, y: Settings.shared.upper_bound+150, width: frame.width, height: CGFloat(i)*(height+20))
        }
        
        print()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


