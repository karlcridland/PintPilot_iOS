//
//  Graph.swift
//  pint pilot
//
//  Created by Karl Cridland on 27/11/2020.
//

import Foundation
import UIKit

class Graph: UIView {
    
}

class BarGraph: Graph {
    
    let width_percent = 5
    
    static var colors: [UIColor] = [#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]
    static var shuffled = false
    
    init(frame: CGRect, dict: [String: Int], special: String?){
        super.init(frame: frame)
        
        let count = CGFloat([dict.count,5].min()!)
        let width = frame.width/CGFloat(11)
        
        if !BarGraph.shuffled{
            BarGraph.colors = BarGraph.colors.shuffled()
            BarGraph.shuffled = true
        }
        
        var max = 0
        var i = 0
        for result in dict.sorted(by: {$0.0 > $1.0}){
            if i == 0{
                max = result.value
            }
            if CGFloat(i) > count{
                return
            }
            let height = CGFloat(result.value)*(frame.height-50)/CGFloat(max)
            let bar = UIView(frame: CGRect(x: CGFloat(i)*(2*width)+width, y: frame.height-25-height, width: width, height: height))
            bar.layer.cornerRadius = 5
            bar.backgroundColor = BarGraph.colors[i%BarGraph.colors.count]
            
            let title = UILabel(frame: CGRect(x: CGFloat(i)*(2*width)+(width/2), y: frame.height-27, width: width*2, height: 25))
            title.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight(0.3))
            title.textAlignment = .center
            title.text = result.key
            
            let value = UILabel(frame: CGRect(x: CGFloat(i)*(2*width)+(width/2), y: bar.frame.minY-25, width: width*2, height: 25))
            value.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight(0.3))
            value.textAlignment = .center
            value.text = result.value.shorten()
            value.textColor = .black
            
            addSubview([title,bar,value])
            i += 1
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
