//
//  Progress.swift
//  pint pilot
//
//  Created by Karl Cridland on 24/11/2020.
//

import Foundation
import UIKit

class Progress: UIView, UIScrollViewDelegate {
    
    let scroll = UIScrollView()
    
    var town: Graph?
    var region: Graph?
    var country: Graph?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        layer.cornerRadius = 10
        
        backgroundColor = .systemGray6
        scroll.frame = CGRect(x: 3, y: 3, width: frame.width-6, height: frame.height-6)
        scroll.showsHorizontalScrollIndicator = false
        scroll.isPagingEnabled = true
        
        addSubview(scroll)
    }
    
    func display(){
        scroll.removeAll()
        var i = 0
        for graph in [town,region,country]{
            if let graph = graph{
                graph.frame = CGRect(x: scroll.frame.width*CGFloat(i), y: graph.frame.minY, width: graph.frame.width, height: graph.frame.height)
                scroll.addSubview(graph)
            }
            else{
                return
            }
            i += 1
        }
        scroll.contentSize = CGSize(width: scroll.frame.width*CGFloat(i), height: scroll.frame.height)
    }
    
    func noDisplay(){
        scroll.removeAll()
        let sorry = UILabel(frame: CGRect(x: 0, y: 0, width: scroll.frame.width, height: scroll.frame.height))
        sorry.textAlignment = .center
        sorry.textColor = .black
        sorry.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight(0.3))
        sorry.numberOfLines = 0
        sorry.text = "no data available\nat this time"
        scroll.addSubview(sorry)
        scroll.contentSize = CGSize(width: scroll.frame.width, height: scroll.frame.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
