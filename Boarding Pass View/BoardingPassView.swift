//
//  BoardingPassView.swift
//  pint pilot
//
//  Created by Karl Cridland on 24/11/2020.
//

import Foundation
import UIKit

class BoardingPassView: ControlView, UIScrollViewDelegate{
    
    var passes = [BoardingPass]()
    
    let scroll = UIScrollView()
    let active = SpecView()
    let archive = SpecView()
    
    var venue_title = [String: String]()
    var venue_color = [String: String]()
    
    override init(){
        super .init()
        
        Firebase.shared.getBoardingPasses(self)
        
        scroll.frame = CGRect(x: 0, y: 80, width: frame.width, height: frame.height-80)
        active.frame = CGRect(x: 0, y: 0, width: frame.width, height: 150)
        archive.frame = CGRect(x: 0, y: 200, width: frame.width, height: 150)
        
        archive.clipsToBounds = true
        
        let passes = SView(title: "passes")
        let aTitle = SView(title: "archive")
        
        active.addSubview(passes)
        archive.addSubview(aTitle)
        
        passes.update()
        aTitle.update()
        
        active.below = archive
        archive.above = active
        
        addSubview(scroll)
        scroll.addSubview([active,archive])
        
    }
    
    func display(){
        var i = 0 // new
        var a = 0 // archived
        
        active.frame = CGRect(x: 0, y: 0, width: frame.width, height: 150)
        archive.frame = CGRect(x: 0, y: 200, width: frame.width, height: 150)
        
        var old = [BoardingPass]()
        var new = [BoardingPass]()
        
        for pass in passes.sorted(by: {$0.id > $1.id}){
            
            if (!pass.isDelivered){     // new
                if (!new.contains(where: {$0.id == pass.id && $0.uid == pass.id})){
                    new.append(pass)
                }
            }
            else{                       // archived
                if (!old.contains(where: {$0.id == pass.id && $0.uid == pass.id})){
                    old.append(pass)
                }
            }
            
        }
        
        for pass in new.reversed(){
            
            pass.display(frame: CGRect(x: 20, y: 50+CGFloat(i)*50, width: scroll.frame.width-40, height: 150), view: self)
            active.frame = CGRect(x: 0, y: 0, width: frame.width, height: active.frame.height+50)
            archive.frame = CGRect(x: 0, y: active.frame.maxY+20, width: frame.width, height: archive.frame.height)
            active.addSubview(pass)
            i += 1
            
        }
        
        for pass in old{
            
            pass.display(frame: CGRect(x: 20, y: 50+CGFloat(a)*50, width: scroll.frame.width-40, height: 150), view: self)
            archive.frame = CGRect(x: 0, y: active.frame.maxY+20, width: frame.width, height: archive.frame.height+50)
            archive.addSubview(pass)
            a += 1
            
        }
        
        if (a == 0){
            archive.frame = CGRect(x: 0, y: active.frame.height, width: frame.width, height: 0)
        }
        
        scroll.contentSize = CGSize(width: scroll.frame.width, height: archive.frame.maxY+50)
    }
    
    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
