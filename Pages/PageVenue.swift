//
//  PageVenue.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

class PageVenue: Page, UIScrollViewDelegate{
    
    let venueView: VenueView?
    let uid: String
    
    let height = 3*UIScreen.main.bounds.width/5
    
    let back = BackgroundView()
    
    let banner = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 3*UIScreen.main.bounds.width/5))
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    let hourView = UIScrollView()
    let wifi = UIView()
    let wifi_image = UIImageView()
    let socials = UIScrollView()
    
    var hourOffset = CGFloat()
    var hasWifi = false
    
    init(_ uid: String, _ venueView: VenueView?, _ openingAt: VenuePageSelection?) {
        self.venueView = venueView
        self.uid = uid
        if let name = venueView?.venue.name{
            super .init(title: name)
        }
        else{
            super .init(title: "")
        }
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        
        Firebase.shared.getTitle(self)
        
        back.frame = CGRect(x: 20, y: height+20, width: frame.width-40, height: view.frame.height-height)
        back.backgroundColor = .systemGray6
        back.layer.borderWidth = 2
        back.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        back.layer.cornerRadius = 10
        
        banner.contentMode = .scaleAspectFill
        banner.clipsToBounds = true
        
        titleLabel.frame = CGRect(x: 40, y: banner.frame.maxY+40, width: frame.width-80, height: 50)
        titleLabel.accessibilityHint = "title"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight(0.3))
        titleLabel.numberOfLines = 0
        
        infoLabel.frame = CGRect(x: 40, y: titleLabel.frame.maxY, width: frame.width-80, height: 100)
        infoLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        infoLabel.numberOfLines = 0
        
        hourOffset = CGFloat(Date.weekdays.firstIndex(of: Date.getDayOfWeek())!)
        
        hourView.frame = CGRect(x: 40, y: infoLabel.frame.maxY, width: frame.width-80, height: 60)
        let expand = UIButton(frame: CGRect(x: 0, y: (hourView.frame.height/2)*(hourOffset+1), width: hourView.frame.width, height: hourView.frame.height/2))
        expand.addTarget(self, action: #selector(viewAllDates), for: .touchUpInside)
        expand.backgroundColor = .systemGray6
        expand.setTitle("view all", for: .normal)
        expand.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        expand.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        hourView.addSubview(expand)
        hourView.isScrollEnabled = false
        hourView.clipsToBounds = true
        
        if let venueView = venueView{
            banner.image = venueView.getImage()
            titleLabel.text = venueView.venue.name
        }
        
        wifi.frame = CGRect(x: 20, y: hourView.frame.maxY+10, width: frame.width-40, height: 100)
        wifi.accessibilityHint = "wifi"
        wifi.backgroundColor = .systemGray6
        wifi.layer.borderWidth = 2
        wifi.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        wifi.layer.cornerRadius = 10
        
        wifi_image.frame = CGRect(x: 0, y: 0, width: wifi.frame.height, height: wifi.frame.height)
        wifi_image.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        wifi_image.image = UIImage(named: "wifi_unavailable")
        wifi.addSubview(wifi_image)
        
        socials.frame = CGRect(x: wifi.frame.minX, y: wifi.frame.maxY+20, width: wifi.frame.width, height: wifi.frame.height)
        socials.backgroundColor = .systemGray6
        socials.layer.borderWidth = 2
        socials.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        socials.layer.cornerRadius = 10
        
        Firebase.shared.getExtraVenueInfo(self)
        
        view.addSubview([back,banner,titleLabel,infoLabel,hourView,wifi,socials])
        
        self.display(nil)
        
        if let openingAt = openingAt{
            
            var highlight: UIView?
            var height: CGFloat?
            
            UIView.animate(withDuration: 0.3, animations: {
                switch openingAt{
                
                case .wifi:
                    highlight = self.wifi
                    break
                    
                case .hours:
                    highlight = self.back
                    height = self.hourView.frame.height
                    self.hourView.frame = CGRect(x: self.hourView.frame.minX, y: self.hourView.frame.minY, width: self.hourView.frame.width, height: 30)
                    break
                    
                default:
                    break
                }
                
                if let highlight = highlight{
                    self.view.contentOffset = CGPoint(x: 0, y: [highlight.frame.minY,self.view.contentOffset.y-self.view.frame.height].min()!)
                }
            })
            
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
                
                if let highlight = highlight{
                    highlight.flash()
                }
                
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                    if let height = height{
                        self.hourView.frame = CGRect(x: self.hourView.frame.minX, y: self.hourView.frame.minY, width: self.hourView.frame.width, height: height)
                        self.update()
                    }
                })
                
            })
        }
    }
    
    func setWifi(_ name: String?, _ password: String?){
        if name == nil{
            let unavailable = UILabel(frame: CGRect(x: wifi.frame.height, y: 0, width: wifi.frame.width-wifi.frame.height, height: wifi.frame.height))
            unavailable.text = "WiFi details unavailable."
            unavailable.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            unavailable.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
            wifi.addSubview(unavailable)
        }
        else{
            
            if let image = wifi.subviews.first(where: {$0 is UIImageView}) as? UIImageView{
                image.image = UIImage(named: "wifi_available")
            }
            
            let name_field = UILabel(frame: CGRect(x: wifi.frame.height, y: 0, width: wifi.frame.width-wifi.frame.height, height: wifi.frame.height/2))
            name_field.text = name!
            name_field.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
            wifi.addSubview(name_field)
            
            let password_field = UILabel(frame: CGRect(x: wifi.frame.height, y: wifi.frame.height/2, width: wifi.frame.width-wifi.frame.height, height: wifi.frame.height/2))
            password_field.text = password!
            password_field.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
            wifi.addSubview(password_field)
        }
    }
    
    func updateSocials(_ social_dict: [String: String]){
        socials.removeAll()
        
        if (social_dict.keys.count == 0){
            let unavailable = UILabel(frame: CGRect(x: 0, y: 0, width: socials.frame.width, height: socials.frame.height))
            unavailable.text = "Social media unavailable."
            unavailable.textAlignment = .center
            unavailable.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            unavailable.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
            socials.addSubview(unavailable)
        }
        else{
            var i = 0
            for social in social_dict.keys{
                let button = UIButton(frame: CGRect(x: (2*socials.frame.height/3)*CGFloat(i), y: 0, width: socials.frame.height, height: socials.frame.height))
                button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                button.setImage(UIImage(named: social), for: .normal)
                socials.addSubview(button)
                button.addLink("https://\(social).com/\(social_dict[social]!)")
                i += 1
            }
        }
    }
    
    var hourExpanded = false
    
    @objc func viewAllDates(sender: UIButton){
        hourExpanded = !hourExpanded
        UIView.animate(withDuration: 0.1, animations: {
            if self.hourExpanded{
                self.hourView.tag = 270
                sender.frame = CGRect(x: sender.frame.minX, y: 240, width: sender.frame.width, height: 30)
                sender.setTitle("just today", for: .normal)
            }
            else{
                self.hourView.tag = 60
                sender.frame = CGRect(x: sender.frame.minX, y: 30*(self.hourOffset+1), width: sender.frame.width, height: 30)
                sender.setTitle("view all", for: .normal)
                
            }
            self.update()
        })
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.update()
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        update()
    }
    
    func display(_ hours: Opening_Hours?) {
        if let hours = venueView?.hours{
            displayHours(hours)
        }
        else{
            displayHours(hours)
        }
    }
    
    private func displayHours(_ hours: Opening_Hours?){
        
        let button = hourView.subviews.first(where: {$0 is UIButton})
        hourView.removeAll()
        if let button = button{
            hourView.addSubview(button)
        }
        if let hours = hours{
            var i = 0
            for oc in [hours.monday,hours.tuesday,hours.wednesday,hours.thursday,hours.friday,hours.saturday,hours.sunday]{
                
                let new = dateView(frame: CGRect(x: 0, y: CGFloat(i)*30, width: hourView.frame.width, height: 30), fields: Date.weekdays[i],oc.open,oc.close)
                self.hourView.addSubview(new)
                self.hourView.sendSubviewToBack(new)
                
                i += 1
            }
            
        }
        update()
        
        hourView.contentOffset = CGPoint(x: 0, y: 30*(hourOffset))
    }
    
    func dateView(frame: CGRect, fields: String ...) -> UIView{
        let dayView = UIView(frame: frame)
        for i in 0 ..< 3{
            let field = UILabel(frame: CGRect(x: CGFloat(i)*frame.width/3, y: 0, width: frame.width/3, height: frame.height))
            field.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
            field.text = fields[i]
            dayView.addSubview(field)
            if i > 0{
                field.textAlignment = .right
            }
        }
        return dayView
    }
    
    func update(){
        
        var previous: UIView?
        UIView.animate(withDuration: 0.01, animations: {
            
            if self.view.contentOffset.y < self.height{
                self.banner.frame = CGRect(x: self.banner.frame.minX, y: [self.view.contentOffset.y,CGFloat(0)].max()!, width: self.banner.frame.width, height: self.height-self.view.contentOffset.y)
            }
            else{
                self.banner.frame = CGRect(x: self.banner.frame.minX, y: self.height-1, width: self.banner.frame.width, height: 1)
            }
            
            for subview in self.view.subviews.sorted(by: {$0.frame.minY < $1.frame.minY}){
                if !(subview is BackgroundView){
                    var buffer = CGFloat(20)
                    if let hint = subview.accessibilityHint{
                        if hint == "title"{
                            buffer += 20
                        }
                        if hint == "wifi"{
                            buffer += 20
                        }
                    }
                    if let p = previous{
                        if subview.tag != 0{
                            subview.frame = CGRect(x: subview.frame.minX, y: p.frame.maxY+buffer, width: subview.frame.width, height: CGFloat(subview.tag))
                        }
                        else{
                            subview.frame = CGRect(x: subview.frame.minX, y: p.frame.maxY+buffer, width: subview.frame.width, height: subview.frame.height)
                        }
                    }
                    subview.tag = 0
                    previous = subview
                }
            }
            self.view.contentSize = CGSize(width: self.view.frame.width, height: (previous?.frame.maxY ?? self.view.frame.height))
            self.back.frame = CGRect(x: 20, y: self.banner.frame.maxY+20, width: self.back.frame.width, height: self.hourView.frame.maxY - self.banner.frame.maxY)
            if self.hourView.frame.height < 100{
                self.hourView.contentOffset = CGPoint(x: 0, y: 30*(self.hourOffset))
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class BackgroundView: UIView {
    
}
