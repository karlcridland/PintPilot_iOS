//
//  ChooseView.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

class ChooseView: UIView {
    
    let view: VenueView
    var tables = UIScrollView()
    
    init(frame: CGRect, view: VenueView) {
        self.view = view
        super .init(frame: frame)
        
        
        if view.isChosen{

            tables = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            tables.isPagingEnabled = false
            
            addSubview([tables])
            
            if view.venue.tables != nil{
                showTables()
            }
            else{
                Firebase.shared.getTables(self)
            }
            
            if let h = Control.shared.homeView{
                
                if view.table != nil{
                    h.menu.ready()
                }
                else{
                    h.menu.unready()
                }
            }
        }
        else{
            backgroundColor = .systemGray5
            layer.borderWidth = 2
            layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
            layer.cornerRadius = 10
            
            let click = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            click.addTarget(self, action: #selector(choose), for: .touchUpInside)
            click.setTitle("  select and\nchoose table", for: .normal)
            click.contentHorizontalAlignment = .center
            click.titleLabel?.numberOfLines = 0
            click.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3)).italic()
            click.contentHorizontalAlignment = .center
            click.setTitleColor(.black, for: .normal)
            click.clipsToBounds = true
            click.layer.cornerRadius = 10
            click.bringSubviewToFront(click.titleLabel!)
            self.click = click
            addSubview(click)
        }
        
    }
    
    var click: UIButton?
    
    var choices = [UIButton]()
    
    func showTables(){
        tables.showsVerticalScrollIndicator = false
        if let t = view.venue.tables{
            var i = 0
            for table in t{
                let choice = UIButton(frame: CGRect(x: 5, y: 5+CGFloat(i)*50, width: tables.frame.width-10, height: 40))
                choices.append(choice)
                choice.setTitleColor(.black, for: .normal)
                choice.accessibilityLabel = table
                choice.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
                choice.contentHorizontalAlignment = .left
                choice.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 0)
                choice.addTarget(self, action: #selector(chooseTable), for: .touchUpInside)
                
                choice.backgroundColor = .systemGray6
                choice.layer.borderWidth = 2
                choice.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
                choice.layer.cornerRadius = 7
                
                tables.addSubview(choice)
                
                if let text = Int(table){
                    choice.setTitle("table: \(text)", for: .normal)
                }
                else{
                    choice.setTitle(table, for: .normal)
                }
                    
                
                i += 1
                
                if let c = view.table{
                    if c == table{
                        choice.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
                        Settings.shared.table = table
                        view.table = table
                    }
                }
            }
            tables.contentSize = CGSize(width: tables.frame.width, height: 50*CGFloat(i)+10)
        }
    }
    
    @objc func chooseTable(sender: UIButton){
        if let home = Control.shared.homeView{
            home.menu.ready()
        }
        for choice in choices{
            choice.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        }
        sender.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        Settings.shared.table = sender.accessibilityLabel!
        view.table = sender.accessibilityLabel!
    }
    
    @objc func choose(){
        for venue in getVenueViews(){
            venue.unchoose()
        }
        view.choose()
    }
    
    func getVenueViews() -> [VenueView]{
        var temp = [VenueView]()
        if let s = view.superview{
            for view in s.subviews{
                if let vview = view as? VenueView{
                    temp.append(vview)
                }
            }
        }
        return temp
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

