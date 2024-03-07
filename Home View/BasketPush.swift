//
//  BasketPush.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

class BasketPush: UIView{
    
    let menuItem: MenuItem
    
    let title = UILabel()
    let info = UILabel()
    let price = UILabel()
    var quantity = 1
    
    let increase = UIButton()
    let decrease = UIButton()
    let confirm = UIButton()
    let img = UIImageView()
    var border = UIView()
    
    private var review: Bool
    
    init(frame: CGRect, menuItem: MenuItem, review: Bool){
        self.menuItem = menuItem
        self.review = review
        super .init(frame: frame)
        backgroundColor = .systemGray6
        
        border = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
        border.backgroundColor = .systemGray3
        addSubview(border)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY-100, width: self.frame.width, height: self.frame.height)
        })
        
        var i = 0
        for label in [title,info,price]{
            label.frame = CGRect(x: 10, y: CGFloat(i)*frame.height/3, width: frame.width-170, height: frame.height/3)
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
            i += 1
        }
        
        title.text = menuItem.item
        price.text = "\(quantity) x \(menuItem.price.price(currency: .GBP))"
        
        if let size = menuItem.size{
            info.text = size
        }
        else{
            price.frame = CGRect(x: 10, y: CGFloat(1)*frame.height/3, width: frame.width-170, height: frame.height/3)
        }
        
        increase.frame = CGRect(x: frame.width-150, y: 0, width: 50, height: 51)
        decrease.frame = CGRect(x: frame.width-150, y: 50, width: 50, height: 51)
        confirm.frame = CGRect(x: frame.width-100, y: 0, width: 100, height: 100)
        
        img.frame = confirm.frame
        img.image = UIImage(named: "basket_plus_blue")
        img.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        
        confirm.addTarget(self, action: #selector(addToBasket), for: .touchUpInside)
        
        for button_plus in [[decrease,-1,"-"],[increase,1,"+"]]{
            if let button = button_plus[0] as? UIButton{
                button.addTarget(self, action: #selector(updatePrice), for: .touchUpInside)
                button.tag = button_plus[1] as! Int
                button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(0.3))
                button.setTitle(button_plus[2] as? String, for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = border.backgroundColor?.cgColor
            }
        }
        
        addSubview([title,info,price,increase,decrease,img,confirm])
    }
    
    func review_item(){
        
        review = true
        
        confirm.removeFromSuperview()
        img.removeFromSuperview()
        border.removeFromSuperview()
        
        increase.frame = CGRect(x: frame.width-50, y: 0, width: 50, height: 51)
        decrease.frame = CGRect(x: frame.width-50, y: 50, width: 50, height: 51)
        
        updatePrice(UIButton())
        
        layer.borderColor = border.backgroundColor?.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
        
        var i = 0
        for label in [title,info,price]{
            label.frame = CGRect(x: 10, y: CGFloat(i)*frame.height/3, width: frame.width-120, height: frame.height/3)
            i += 1
        }
    }
    
    @objc func addToBasket(){
        remove(true)
        Basket.shared.append(self)
        if let page = menuItem.superview?.superview as? PageMenu{
            UIView.animate(withDuration: 0.3, animations: {
                page.main_menus.frame = CGRect(x: page.main_menus.frame.minX, y: page.main_menus.frame.minY, width: page.frame.width-47, height: page.main_menus.frame.height)
            })
        }
    }
    
    @objc func updatePrice(_ sender: UIButton){
        quantity += sender.tag
        checkQuantity()
        price.text = "\(quantity) x \(menuItem.price.price(currency: .GBP))"
        Control.shared.updateCheckoutTotal()
    }
    
    func checkQuantity(){
        if review{
            if quantity < 0{
                quantity = 0
            }
        }
        else{
            if quantity < 1{
                quantity = 1
            }
        }
    }
    
    func remove(_ clear: Bool){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY+100, width: self.frame.width, height: self.frame.height)
        })
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            self.removeFromSuperview()
        })
        
        if clear{
            menuItem.reset()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
