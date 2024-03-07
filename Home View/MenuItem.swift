//
//  MenuItem.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

class MenuItem: UIView {
    
    let click = UIButton()
    let item: String
    let size: String?
    let price: Int
    
    let cat: String
    let subCat: String
    
    var others = [MenuItem]()
    
    private var title = UILabel()
    private var prc = UILabel()
    
    init(frame: CGRect, item: String, size: String?, price: Int, cat: String, subCat: String){
        self.item = item
        self.size = size
        self.price = price
        self.cat = cat
        self.subCat = subCat
        super .init(frame: frame)
        
        click.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        layer.borderWidth = 3
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.3).cgColor
        layer.cornerRadius = 10
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        backgroundColor = .systemGray6
        
        title = UILabel(frame: CGRect(x: 20, y: 0, width: frame.width-140, height: frame.height))
        if let s = size{
            title.text = "\(item)\n\(s)"
        }
        else{
            title.text = item
        }
        
        prc = UILabel(frame: CGRect(x: 20, y: 0, width: frame.width-60, height: frame.height))
        prc.textAlignment = .right
        prc.text = price.price(currency: .GBP)+"\n"
        
        for label in [prc,title]{
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
            
        }
        
        addSubview([title,prc,click])
        click.addTarget(self, action: #selector(highlight), for: .touchUpInside)
    }
    
    func reset(){
        for item in others{
            item.color(.black)
        }
    }
    
    func color(_ color: UIColor){
        title.textColor = color
        prc.textColor = color
    }
    
    @objc func highlight(){
        reset()
        color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
