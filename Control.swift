//
//  Control.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit

class Control {
    
    public static let shared = Control()
    
    private let bar = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-Settings.shared.lower_bound-50, width: UIScreen.main.bounds.width, height: 50+Settings.shared.lower_bound))
    private let back = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
    private var buttons = [UIButton]()
    
    private let chosen = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/3, height: 2))
    
    private let banner = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-Settings.shared.lower_bound-50, width: UIScreen.main.bounds.width, height: 50))
    private let title = UILabel()
    
    var homeView: HomeView?
    var boardingView: BoardingPassView?
    var settingsView: SettingsView?
    
    private let options = ["home","boarding pass","settings"]
    
    private var pages = [Page]()
    
    private init(){
        var i = 0
        for option in options{
            let width = bar.frame.width/CGFloat(options.count)
            let button = UIButton(frame: CGRect(x: CGFloat(i)*width, y: 0, width: width, height: 50))
            buttons.append(button)
            button.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
            button.accessibilityLabel = option
            button.tag = i
            button.setTitleColor(.black, for: .normal)
            button.setTitle(option, for: .normal)
            bar.addSubview(button)
            i += 1
        }
        
        chosen.backgroundColor = .black
        bar.addSubview(chosen)
        bar.backgroundColor = .systemGray6
        banner.isHidden = true
        banner.backgroundColor = .systemGray6
        
        let border = UIView(frame: CGRect(x: 0, y: 0, width: banner.frame.width, height: 1))
        border.backgroundColor = .systemGray3
        banner.addSubview(border)
        
        title.frame = CGRect(x: 80, y: 0, width: border.frame.width-100, height: 50)
        title.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
        title.textAlignment = .right
        
        back.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        back.contentHorizontalAlignment = .left
        back.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        back.setTitle("back", for: .normal)
        back.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        back.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
        banner.addSubview([back,title])
        
        if let home = Settings.shared.home{
            home.view.addSubview([bar,banner])
        }
    }
    
    func reloadDaTing(){
        if let home = Settings.shared.home{
            home.view.addSubview([bar,banner])
            openMenu(sender: buttons[0])
        }
    }
    
    func getView(_ option: Control_Options) -> ControlView?{
        let results = ["home":homeView, "boarding_pass":boardingView, "settings":settingsView]
        return results[option.rawValue]!
    }
    
    func updateCheckoutTotal(){
        if let page = pages.last as? PageCheckout{
            page.updateTotal()
        }
    }
    
    func paymentStarted(_ status: Bool){
        if let last = pages.last as? PagePayment{
            last.processing = status
            back.isHidden = status
        }
    }
    
    func resetBasketEmpties(){
        if let page = pages.last as? PageMenu{
            UIView.animate(withDuration: 0.3, animations: {
                if (Basket.shared.get().count > 0){
                    page.main_menus.frame = CGRect(x: page.main_menus.frame.minX, y: page.main_menus.frame.minY, width: page.frame.width-47, height: page.main_menus.frame.height)
                }
                else{
                    page.main_menus.frame = CGRect(x: page.main_menus.frame.minX, y: page.main_menus.frame.minY, width: page.frame.width+6, height: page.main_menus.frame.height)
                }
            })
        }
    }
    
    func append(_ page: Page){
        pages.append(page)
        banner.isHidden = false
        back.isHidden = false
        
        if let home = Settings.shared.home{
            home.view.addSubview(page)
        }
        
        update()
    }
    
    @objc func remove(){
        if pages.count == 1{
            banner.isHidden = true
        }
        if let last = pages.last{
            last.disappear()
            pages.removeLast()
            
            if last is PageOrderPlaced{
                removeAll()
            }
        }
        else{
            print("HOW??!!?!")
        }
        
        update()
        resetBasketEmpties()
    }
    
    func removeAll(){
        while pages.count > 0{
            remove()
        }
    }
    
    func update(){
        if let last = pages.last{
            title.text = last.title
        }
    }
    
    @objc func openMenu(sender: UIButton){
        open(Control_Options.init(rawValue: sender.accessibilityLabel!.replacingOccurrences(of: " ", with: "_"))!)
        UIView.animate(withDuration: 0.2, animations: {
            self.chosen.frame = CGRect(x: CGFloat(sender.tag)*self.chosen.frame.width, y: 0, width: self.chosen.frame.width, height: 2)
        })
    }
    
    func open(_ option: Control_Options) {
        var v: ControlView?
        if let home = Settings.shared.home{
            home.view.subviews.first(where: {$0 is ControlView})?.removeFromSuperview()
            switch option {
            case .home:
                if homeView == nil{
                    homeView = HomeView()
                }
                home.view.addSubview(homeView!)
                v = homeView!
                break
            case .boarding_pass:
                if boardingView == nil{
                    boardingView = BoardingPassView()
                }
                boardingView!.active.resetViews()
                for pass in boardingView!.active.allPasses(){
                    pass.isSelected = false
                }
                home.view.addSubview(boardingView!)
                v = boardingView!
                break
            case .settings:
                if settingsView == nil{
                    settingsView = SettingsView()
                }
                settingsView!.resetPic()
                home.view.addSubview(settingsView!)
                v = settingsView!
                break
            }
            if let v = v{
                v.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }
    
}
