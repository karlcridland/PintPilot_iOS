//
//  PageCheckout.swift
//  pint pilot
//
//  Created by Karl Cridland on 26/11/2020.
//

import Foundation
import UIKit

class PageCheckout: Page{
    
    let page: PageMenu
    let checkout = UIView()
    
    private let total = UILabel()
    private var order = UIButton()
    
    init(page: PageMenu) {
        self.page = page
        super .init(title: "\(Settings.shared.venues.first(where: {$0.uid == Settings.shared.venue!})!.name!): Checkout")
        
        display()
        view.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height-150)
        
        checkout.frame = CGRect(x: -1, y: view.frame.maxY, width: view.frame.width+2, height: 151)
        checkout.layer.borderColor = UIColor.systemGray3.cgColor
        checkout.layer.borderWidth = 1
        checkout.backgroundColor = .systemGray6
        addSubview(checkout)
        
        order = UIButton(frame: CGRect(x: checkout.frame.width-100, y: 0, width: 100, height: 40))
        order.setTitle("purchase", for: .normal)
        order.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        order.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        order.addTarget(self, action: #selector(placeOrder), for: .touchUpInside)
        
        let title = UILabel(frame: CGRect(x: 10, y: 40, width: checkout.frame.width-120, height: 30))
        title.text = Settings.shared.venues.first(where: {$0.uid == Settings.shared.venue!})!.name
        title.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        
        let table = UILabel(frame: CGRect(x: 10, y: 70, width: checkout.frame.width-120, height: 30))
        table.text = "Table: \(Settings.shared.table!)"
        table.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
        
        total.frame = CGRect(x: 10, y: 100, width: checkout.frame.width-120, height: 30)
        total.text = "Total: \(Basket.shared.getTotal().price(currency: .GBP))"
        total.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
        
        checkout.addSubview([order,title,table,total])
    }
    
    func display() {
        view.removeAll()
        var i = 0
        for item in Basket.shared.get(){
            item.frame = CGRect(x: item.frame.minX-1, y: (item.frame.height+10)*CGFloat(i), width: item.frame.width+1, height: item.frame.height)
            item.review_item()
            view.addSubview(item)
            i += 1
        }
        view.contentSize = CGSize(width: view.frame.width, height: (110)*CGFloat(i))
    }
    
    @objc func placeOrder(){
        if (Basket.shared.getTotal() > 0){
            Basket.shared.removeEmpties()
            display()
            let _ = PagePayment()
//            let _ = PageOrderPlaced()
        }
    }
    
    func updateTotal(){
        let t = Basket.shared.getTotal()
        total.text = "Total: \(t.price(currency: .GBP))"
        
        if t == 0{
            order.alpha = 0.5
        }
        else{
            order.alpha = 1
        }
    }
    
    override func disappear() {
        super.disappear()
        Basket.shared.removeEmpties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
