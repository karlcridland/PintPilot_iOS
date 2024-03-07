//
//  VenueView.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

class VenueView: UIView{
    
    let venue: Venue
    var isChosen = false
    var table: String?
    
    private let value = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
    private let title = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
    private let pic = UIImageView()
    private var choice: ChooseView?
    private var img: UIImage?
    
    private let wifi = UIButton()
    private let dist = UIButton()
    private let open = UIButton()
    
    var menu: [String:[String:[String:[String:Int]]]]?
    
    let location = UILabel(frame: CGRect(x: 10, y: 40, width: 100, height: 20))
    var location_string: String?
    var hours: Opening_Hours?
    
    init(frame: CGRect, venue: Venue) {
        self.venue = venue
        super .init(frame: frame)
        
        Firebase.shared.getVenueInfo(self)
        Firebase.shared.getMenu(self)
        
        value.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.9)
        value.textAlignment = .center
        value.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(0.3))
        value.layer.cornerRadius = 2
        value.clipsToBounds = true
        value.isHidden = true
        
        title.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        title.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        location.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        location.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        pic.frame = CGRect(x: frame.width-60, y: 10, width: 50, height: 50)
        pic.layer.borderWidth = 2
        pic.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        pic.layer.cornerRadius = 25
        pic.contentMode = .scaleAspectFill
        pic.clipsToBounds = true
        pic.getImage(path: "venues/\(venue.uid)", {
            self.img = self.pic.image
        })
        
        func getY(_ p: Int) -> CGFloat{
            let h = frame.height-35
            let gap = (h-200)/3
            return CGFloat(p)*CGFloat(gap+50)+15
        }
        
        dist.frame = CGRect(x: frame.width-60, y: getY(1), width: 50, height: 50)
        wifi.frame = CGRect(x: frame.width-60, y: getY(2), width: 50, height: 50)
        open.frame = CGRect(x: frame.width-60, y: getY(3), width: 50, height: 50)
        
        wifi.setImage(UIImage(named: "wifi_unavailable"), for: .normal)
        wifi.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        wifi.addTarget(self, action: #selector(openPage), for: .touchUpInside)
        wifi.accessibilityElements = [VenuePageSelection.wifi]
        
        open.titleLabel?.numberOfLines = 0
        open.titleLabel?.textAlignment = .center
        open.contentHorizontalAlignment = .center
        open.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight(0.3))
        open.addTarget(self, action: #selector(openPage), for: .touchUpInside)
        open.accessibilityElements = [VenuePageSelection.hours]
        
        dist.addTarget(self, action: #selector(openPage), for: .touchUpInside)
        dist.accessibilityElements = [VenuePageSelection.hours]
        dist.titleLabel?.numberOfLines = 0
        dist.titleLabel?.textAlignment = .center
        dist.contentHorizontalAlignment = .center
        dist.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight(0.3))
        if let distance = venue.dist{
            dist.setTitle("\(distance/10).\(distance%10)km\naway", for: .normal)
            if distance < 50{
                dist.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
            }
            else{
                dist.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
            }
        }
        
        addSubview([title,location,pic,value,wifi,open,dist])
    }
    
    func displayOpen(){
        let todays_hours = getOpeningTimes(Date.getDayOfWeek())!
        let tomorrows_hours = getOpeningTimes(Date.tomorrow())!
        
        let val = isOpen(Date.time(), todays_hours.open, todays_hours.close)
        
        open.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
        open.setTitle("closed\nuntil\n\(todays_hours.open)", for: .normal)
        if val == 0{
            open.setTitle("open\nuntil\n\(todays_hours.close)", for: .normal)
            open.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        }
        else{
            open.setTitle("closed\nuntil\n\(tomorrows_hours.open)", for: .normal)
        }
        
    }
    
    func isOpen(_ current_time: String, _ today_open: String, _ today_close: String) -> Int{
        if current_time.hours() < today_open.hours(){
            return -1
        }
        else if current_time.hours() < today_close.hours(){
            return 0
        }
        else if current_time.hours() == today_close.hours(){
            if current_time.minutes() < today_close.minutes(){
                return 0
            }
        }
        return 1
    }
    
    func getOpeningTimes(_ day: String) -> Open_Close?{
        if let hours = hours{
            var openClose: Open_Close?
            switch day {
            case "monday":
                openClose = hours.monday
                break
            case "tuesday":
                openClose = hours.tuesday
                break
            case "wednesday":
                openClose = hours.wednesday
                break
            case "thursday":
                openClose = hours.thursday
                break
            case "friday":
                openClose = hours.friday
                break
            case "saturday":
                openClose = hours.saturday
                break
            case "sunday":
                openClose = hours.sunday
                break
            default:
                break
            }
            if let openClose = openClose{
                return openClose
            }
        }
        return nil
    }
    
    func wifiAvailable(){
        wifi.setImage(UIImage(named: "wifi_available"), for: .normal)
    }
    
    @objc func openPage(_ sender: UIButton?){
        if let sender = sender{
            if let type = sender.accessibilityElements?[0] as? VenuePageSelection{
                let _ = PageVenue(venue.uid,self,type)
            }
        }
        else{
            let _ = PageVenue(venue.uid,self,nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        openPage(nil)
    }
    
    func display(){
        title.text = venue.name
    }
    
    func choose(){
        if (Basket.shared.get().count > 0){
            let alert = UIAlertController(title: "Empty Basket?", message: "If you continue you will lose the contents of your basket, do you want to continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "no", style: .default, handler: { _ in
                if let suggestions = self.superview{
                    if let current = suggestions.subviews.first(where: {($0 as? VenueView)?.venue.uid == Settings.shared.venue}) as? VenueView{
                        current.choose_func()
                    }
                }
                
            }))
            alert.addAction(UIAlertAction(title: "yes", style: .default, handler: { _ in
                Basket.shared.empty()
                self.choose_func()
            }))
            if let home = Settings.shared.home{
                home.present(alert, animated: true)
            }
        }
        else{
            choose_func()
        }
    }
    
    func choose_func(){
        isChosen = true
        pic.layer.borderColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        title.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        location.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        title.frame = CGRect(x: 10, y: 10, width: frame.width-100, height: 20)
        location.frame = CGRect(x: 10, y: 40, width: frame.width-20, height: 20)
        
        if let choice = choice{
            choice.removeFromSuperview()
        }
        
        choice = ChooseView(frame: CGRect(x: 10, y: 70, width: frame.width-80, height: frame.height-90), view: self)
        addSubview(choice!)
        
        if let suggestions = Control.shared.homeView?.suggestions{
            suggestions.update(venue)
        }
        
        Settings.shared.venue = venue.uid
        if table == nil{
            Settings.shared.table = nil
        }
        
    }
    
    
    func unchoose(){
        isChosen = false
        title.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        location.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        backgroundColor = .clear
        pic.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        title.frame = CGRect(x: 10, y: 10, width: frame.width-110, height: 20)
        location.frame = CGRect(x: 10, y: 40, width: frame.width-20, height: 20)
        
        if let choice = choice{
            choice.removeFromSuperview()
        }
        
        choice = ChooseView(frame: CGRect(x: 10, y: 70, width: frame.width-80, height: frame.height-90), view: self)
        addSubview(choice!)
    }
    
    func getImage() -> UIImage?{
        return pic.image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
