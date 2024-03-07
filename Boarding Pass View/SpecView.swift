//
//  SpecView.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

class SpecView: UIView {
    
    var above: SpecView?
    var below: SpecView?
    
    func position(_ pass: BoardingPass, _ passes: [BoardingPass]) -> Int{
        return passes.firstIndex(of: pass)!
    }
    
    func focus(_ highlighted: BoardingPass){
        topView().resetViews()
        var passes = [BoardingPass]()
        var h = false
        for subview in subviews{
            if let pass = subview as? BoardingPass{
                passes.append(pass)
                if pass.isSelected{
                    h = true
                }
            }
        }
        if !h && passes.count-1 == position(highlighted, passes){
            let _ = PageBoardingPass(pass: highlighted)
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            var max = CGFloat()
            var i = 0
            var j = 1
            let p = self.position(highlighted, passes)
            for pass in passes{
//                if pass == highlighted{
//                    pass.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
//                }
                if i > p{
                    pass.frame = CGRect(x: pass.frame.minX, y: highlighted.frame.maxY+(50*CGFloat(j)), width: pass.frame.width, height: pass.frame.height)
                    j += 1
                }
                max = [max,pass.frame.maxY].max()!
                i += 1
            }
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: max)
            if let below = self.below{
                below.frame = CGRect(x: below.frame.minX, y: self.frame.maxY+20, width: below.frame.width, height: below.frame.height)
                below.resetViews()
            }
            else{
                if let s = self.superview as? UIScrollView{
                    s.contentSize = CGSize(width: s.frame.width, height: self.frame.maxY+50)
                }
            }
            
            if let s = self.superview as? UIScrollView{
                if (highlighted.frame.maxY > s.contentOffset.y+s.frame.height){
                    s.contentOffset = CGPoint(x: 0, y: highlighted.frame.maxY-highlighted.frame.height+50)
                }
            }
        })
        
        if highlighted.isSelected{
            let _ = PageBoardingPass(pass: highlighted)
            highlighted.isSelected  = false
            resetViews()
        }
        else{
            for pass in allPasses(){
                pass.isSelected = false
            }
            highlighted.isSelected  = true
        }
    }
    
    func topView() -> SpecView{
        if let above = above{
            return above.topView()
        }
        return self
    }
    
    func allPasses() -> [BoardingPass]{
        return topView().getPasses()
    }
    
    private func getPasses() -> [BoardingPass]{
        var passes = [BoardingPass]()
        for subview in subviews{
            if let pass = subview as? BoardingPass{
                passes.append(pass)
            }
        }
        if let below = below{
            for pass in below.getPasses(){
                passes.append(pass)
            }
        }
        return passes
    }
    
    func resetViews(){
        var passes = [BoardingPass]()
        for subview in subviews{
            if let pass = subview as? BoardingPass{
                passes.append(pass)
            }
        }
        UIView.animate(withDuration: 0.2, animations: {
            var i = 0
            var max = CGFloat()
            for pass in passes.sorted(by: {$0.id  < $1.id}){
                pass.transform = CGAffineTransform(scaleX: 1, y: 1)
                pass.frame = CGRect(x: pass.frame.minX, y: 50+CGFloat(i)*50, width: pass.frame.width, height: pass.frame.height)
                max = [max,pass.frame.maxY].max()!
                self.bringSubviewToFront(pass)
                i += 1
            }
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: max)
            if let below = self.below{
                below.frame = CGRect(x: below.frame.minX, y: self.frame.maxY+20, width: below.frame.width, height: below.frame.height)
                below.resetViews()
            }
            else{
                if let s = self.superview as? UIScrollView{
                    s.contentSize = CGSize(width: s.frame.width, height: self.frame.maxY+50)
                }
            }
        })
    }
    
}
