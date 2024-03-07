//
//  PageMenu.swift
//  pint pilot
//
//  Created by Karl Cridland on 25/11/2020.
//

import Foundation
import UIKit

class PageMenu: Page, UIScrollViewDelegate{
    
    let venue: VenueView
    
    let main_menus = UIScrollView(frame: CGRect(x: -3, y: Settings.shared.upper_bound, width: UIScreen.main.bounds.width+6, height: 50))
    let sub_menus = UIScrollView(frame: CGRect(x: -3, y: Settings.shared.upper_bound+60, width: UIScreen.main.bounds.width+6, height: 50))
    
    let basket_icon = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width-53, y: Settings.shared.upper_bound, width: 50, height: 50))
    let basket = UIButton()
    
    var current: String?
    
    init(venue: VenueView) {
        self.venue = venue
        super .init(title: "\(venue.venue.name!): Menu")
        
        view.delegate = self
        addSubview([basket_icon,basket,main_menus,sub_menus])
        view.frame = CGRect(x: 0, y: view.frame.minY+110, width: frame.width, height: view.frame.height-110)
        
        basket_icon.image = UIImage(named: "basket_blue")
        basket_icon.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        basket.frame = basket_icon.frame
        basket.addTarget(self, action: #selector(checkOut), for: .touchUpInside)
        
        if (Basket.shared.get().count > 0){
            UIView.animate(withDuration: 0.3, animations: {
                self.main_menus.frame = CGRect(x: self.main_menus.frame.minX, y: self.main_menus.frame.minY, width: self.frame.width-47, height: self.main_menus.frame.height)
            })
        }
        
        for scroll in [main_menus,sub_menus]{
            scroll.backgroundColor = .systemGray6
            scroll.layer.borderWidth = 3
            scroll.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.3).cgColor
        }
        
        if let menu = venue.menu{
            var i = 0
            var buttons = [UIButton]()
            var options = [String]()
            for m in menu.keys.sorted(){
                options.append(m)
            }
            options.append("search")
            for m in options{
                let button = UIButton(frame: CGRect(x: 100*CGFloat(i), y: 0, width: 100, height: 50))
                buttons.append(button)
                if m == "search"{
                    
                }
                else{
                    if let table = Settings.shared.table{
                        if table == "collect from bar" && m == "food"{
                            button.setTitleColor(#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1), for: .normal)
                            button.addTarget(self, action: #selector(foodFromBar), for: .touchUpInside)
                        }
                        else{
                            button.addTarget(self, action: #selector(openMainMenu), for: .touchUpInside)
                        }
                    }
                }
                button.setTitle(m.lowercased(), for: .normal)
                button.accessibilityLabel = m
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
                button.titleLabel?.numberOfLines = 0
                button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
                main_menus.addSubview(button)
                
                i += 1
            }
            
            openMainMenu(buttons[0])
            main_menus.contentSize = CGSize(width: CGFloat(i)*100, height: 50)
            
            for button in buttons{
                button.accessibilityElements = buttons
            }
        }
        else{
            isHidden = true
            background.isHidden = true
            let alert = UIAlertController(title: "Unavailable", message: "\(venue.venue.name!) has no menu at this time.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
            if let home = Settings.shared.home{
                home.present(alert, animated: true)
            }
            Control.shared.remove()
        }
    }
    
    @objc func foodFromBar(){
        let alert = UIAlertController(title: "Food from the bar?!", message: "Your table is set to collect from the bar, silly.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        if let home = Settings.shared.home{
            home.present(alert, animated: true)
        }
    }
    
    @objc func checkOut(){
        let _ = PageCheckout(page: self)
    }
    
    @objc func openMainMenu(_ sender: UIButton){
        if let buttons = sender.accessibilityElements as? [UIButton]{
            for button in buttons{
                button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
            }
        }
        sender.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        sub_menus.removeAll()
        if let menu = sender.accessibilityLabel{
            current = menu
            if let sub_menu = venue.menu?[menu]{
                var i = 0
                var buttons = [UIButton]()
                for m in sub_menu.keys.sorted(){
                    let button = UIButton(frame: CGRect(x: 100*CGFloat(i), y: 0, width: 100, height: 50))
                    buttons.append(button)
                    button.addTarget(self, action: #selector(openSubMenu), for: .touchUpInside)
                    button.setTitle(m.lowercased(), for: .normal)
                    button.accessibilityLabel = m
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
                    button.titleLabel?.numberOfLines = 0
                    button.contentHorizontalAlignment = .center
                    button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
                    sub_menus.addSubview(button)
                    
                    if (i == 0){
                        openSubMenu(button)
                    }
                    
                    i += 1
                }
                sub_menus.contentSize = CGSize(width: CGFloat(i)*100, height: 50)
                
                for button in buttons{
                    button.accessibilityElements = buttons
                }
            }
        }
        if let basketPush = basketPush{
            basketPush.remove(true)
            self.basketPush = nil
        }
    }
    
    var items = [MenuItem]()
    
    @objc func openSubMenu(_ sender: UIButton){
        view.removeAll()
        items.removeAll()
        if let buttons = sender.accessibilityElements as? [UIButton]{
            for button in buttons{
                button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
            }
        }
        sender.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        var i = 0
        if let sub = sender.accessibilityLabel{
            if let menu = current{
                if let menus = venue.menu?[menu]?[sub]{
                    for item in menus.keys.sorted(){
                        for size in menus[item]!{
                            let new = MenuItem(frame: CGRect(x: 0, y: 10+CGFloat(i)*100, width: view.frame.width, height: 100), item: item, size: size.key, price: Int(size.value), cat: menu, subCat: sub)
                            items.append(new)
                            new.click.addTarget(self, action: #selector(addToBasket), for: .touchUpInside)
                            new.click.accessibilityElements = [new]
                            view.addSubview(new)
                            
                            i += 1
                        }
                    }
                    
                    view.contentSize = CGSize(width: view.frame.width, height: CGFloat(i)*100+120)
                }
            }
        }
        if let basketPush = basketPush{
            basketPush.remove(true)
            self.basketPush = nil
        }
        for item in items{
            item.others = items
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let basketPush = basketPush{
            basketPush.remove(true)
            self.basketPush = nil
        }
    }
    
    @objc func addToBasket(sender: UIButton){
        if let basketPush = basketPush{
            basketPush.remove(false)
            self.basketPush = nil
        }
        if let menuItem = sender.accessibilityElements?[0] as? MenuItem{
            let basketPush = BasketPush(frame: CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: 100), menuItem: menuItem, review: false)
            addSubview(basketPush)
            self.basketPush = basketPush
        }
        
    }
    
    var basketPush: BasketPush?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
