//
//  Suggestions.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit

class Suggestions: UIView, UIScrollViewDelegate {
    
    let scroll = UIScrollView()
    let venues: [Venue]
    var length = CGFloat()
    private var position = UIView()
    
    init(frame: CGRect, venues: [Venue]) {
        self.venues = venues
        super .init(frame: frame)
        
        backgroundColor = .systemGray6
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        layer.cornerRadius = 10
        
        scroll.frame = CGRect(x: 3, y: 3, width: frame.width-6, height: frame.height-6)
        scroll.showsHorizontalScrollIndicator = false
        scroll.isPagingEnabled = true
        
        for venue in venues{
            if !scroll.subviews.contains(where: {($0 as! VenueView).venue.uid == venue.uid}){
                let venueView = VenueView(frame: CGRect(x: CGFloat(scroll.subviews.count)*scroll.frame.width, y: 0, width: scroll.frame.width, height: scroll.frame.height), venue: venue)
                scroll.addSubview(venueView)
                
                if let v = Settings.shared.venue{
                    if venue.uid == v{
                        venueView.choose()
                    }
                    else{
                        venueView.unchoose()
                    }
                }
                else{
                    venueView.unchoose()
                }
            }
        }
        
        scroll.contentSize = CGSize(width: CGFloat(venues.count)*scroll.frame.width, height: scroll.frame.height)
        
        length = scroll.frame.width/CGFloat(venues.count)-16
        position = UIView(frame: CGRect(x: 13, y: frame.height-18, width: length, height: 10))
        position.layer.cornerRadius = 5
        position.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        scroll.delegate = self
        
        addSubview([position,scroll])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging{
            // moving regardless of user input
        }
        if scrollView.isTracking{
            // user input
            
            let p = (100/(scrollView.contentSize.width-(scrollView.frame.width)))*scrollView.contentOffset.x*0.95
            let x = [[((self.frame.width)*(p/100)),CGFloat(0)].max()!,self.frame.width-33].min()!+13
            
            
            UIView.animate(withDuration: 0.1, animations: {
                self.position.frame = CGRect(x: x, y: self.frame.height-18, width: 10, height: 10)
            })
            
        }
        if scrollView.isDragging && !scrollView.isTracking{
            
        }
        if !scroll.isTracking{
            let x = CGFloat(Int(((scrollView.contentOffset.x+(scrollView.frame.width/2))/scrollView.frame.width)))*(length+16)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.position.frame = CGRect(x: CGFloat(x)+13, y: self.frame.height-18, width: self.length, height: 10)
            })
        }
    }
    
    func update(_ venue: Venue) {
        var i = 0
        for v in venues{
            if venue.uid == v.uid{
                updateBar(i)
            }
            i += 1
        }
    }
    
    private func updateBar(_ i: Int){
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
