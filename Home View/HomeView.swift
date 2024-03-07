//
//  Home.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit
import CoreLocation
import UserNotifications

class HomeView: ControlView, CLLocationManagerDelegate {
    
    let order = UIView()
    let menu = HomeButton(frame: CGRect(x: 20, y: 20, width: (UIScreen.main.bounds.width-60)/2, height: 50), title: "menu")
    let refresh = HomeButton(frame: CGRect(x: (UIScreen.main.bounds.width)/2+10, y:20, width: (UIScreen.main.bounds.width-60)/2, height: 50), title: "refresh")
    var scores = [String: Int]()
    
    var suggestions: Suggestions?
    var progress: Progress?
    
    var hasScores = false
    
    override init() {
        super .init()
        
        let height = (frame.height-190)/2
        
        let pint = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width/2-50, height: 80))
        let pilot = UILabel(frame: CGRect(x: frame.width/2+50, y: 0, width: frame.width/2-30, height: 80))
        
        pint.text = "pint"
        pilot.text = "pilot"
        
        for label in [pint,pilot]{
            label.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(0.5)).italic()
            addSubview(label)
        }
        
        pint.textAlignment = .right
        pilot.textAlignment = .left
        
        order.frame = CGRect(x: 0, y: height+60, width: frame.width, height: height+110)
        
        menu.frame = CGRect(x: menu.frame.minX, y: order.frame.height-menu.frame.height, width: menu.frame.width, height: menu.frame.height)
        refresh.frame = CGRect(x: refresh.frame.minX, y: order.frame.height-refresh.frame.height, width: refresh.frame.width, height: refresh.frame.height)
        
        menu.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        refresh.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        
        progress = Progress(frame: CGRect(x: 20, y: 80, width: frame.width-40, height: height-20))
        
        addSubview([order,progress!])
        order.addSubview([menu,refresh])
        
        refresh.addTarget(self, action: #selector(refreshClicked), for: .touchUpInside)
        menu.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        
        Firebase.shared.getScores(self)
    }
    
    func updateScores(_ scores: Bool){
        
        var closest: String?
        
        if let suggestions = suggestions{
            if let venue = suggestions.scroll.subviews.sorted(by: {$0.frame.minX < $1.frame.minX}).first as? VenueView{
                closest = venue.venue.uid
            }
        }
        
        if scores{
            let towns = setUpScores(closest, Firebase.shared.town)
            let regions = setUpScores(closest, Firebase.shared.region)
            let countries = setUpScores(closest, Firebase.shared.country)
            if let progress = progress{
                progress.town = towns
                progress.region = regions
                progress.country = countries
                progress.display()
                self.hasScores = true
            }
        }
        else{
            if let progress = progress{
                progress.noDisplay()
            }
        }
        
    }
    
    func setUpScores(_ closest: String?, _ dict: [String:[String]]) -> Graph{
        
        var myTown: String?
        var scores = [String: Int]()
        
        for region in dict{
            var score = 0
            for venue in region.value{
                if let val = Firebase.shared.bar[venue]{
                    score += val
                }
                
                if let closest = closest{
                    if venue == closest{
                        myTown = region.key
                    }
                }
            }
            scores[region.key] = score
        }
        return BarGraph(frame: CGRect(x: 0, y: 0, width: progress!.frame.width, height: progress!.frame.height), dict: scores, special: myTown)
    }
    
    @objc func openMenu(){
        if let venue = Settings.shared.venue{
            if let _ = Settings.shared.table{
                if let suggestions = suggestions{
                    if let view = suggestions.scroll.subviews.first(where: {($0 as? VenueView)?.venue.uid == venue}) as? VenueView{
                        let _ = PageMenu(venue: view)
                    }
                }
            }
            else{
                createAlert("Where you at?!", "You need to let us know which table you're sitting at!")
            }
        }
        else{
            createAlert("No Venue Selected", "Select a venue to touch down at first!")
        }
    }
    
    private func createAlert(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        if let home = Settings.shared.home{
            home.present(alert, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var venues = [Venue]()
    
    let notificationCenter = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    
    func suggest() {
        
        venues = []
        if let suggestions = suggestions{
            suggestions.removeFromSuperview()
        }
        
        if let location = locationManager.location{
            if let h = Control.shared.homeView{
                if h.refresh.isReady{
                    Settings.shared.venues.sort(by: {$0.location.getDistance(location.coordinate) < $1.location.getDistance(location.coordinate)})
                    for i in 0 ..< [5,Settings.shared.venues.count].min()!{
                        venues.append(Settings.shared.venues[i])
                        Settings.shared.venues[i].distance(location.coordinate)
                    }
                }
            }
            suggestions = Suggestions(frame: CGRect(x: 20, y: 20, width: frame.width-40, height: order.frame.height-90), venues: venues)
            order.addSubview(suggestions!)
        }
        else{
            locationManager.requestWhenInUseAuthorization()
            suggestions = Suggestions(frame: CGRect(x: 20, y: 20, width: frame.width-40, height: order.frame.height-90), venues: [])
            order.addSubview(suggestions!)
            
            let warning = UILabel(frame: CGRect(x: 0, y: 0, width: suggestions!.frame.width, height: suggestions!.frame.height))
            warning.numberOfLines = 0
            suggestions!.addSubview(warning)
            
            warning.text = "Location services needed\nto be turned on to use the app.\n\n\nSettings > pint pilot >\nLocation > While Using the App\n\n\nClick refresh when complete."
            warning.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight(0.3))
            warning.textAlignment = .center
        }
    }
    
    @objc func refreshClicked(){
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
        if let suggestions = suggestions{
            suggestions.scroll.removeAll()
            let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: suggestions.scroll.frame.width, height: suggestions.scroll.frame.height))
            activity.startAnimating()
            activity.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            suggestions.scroll.addSubview(activity)
            suggestions.scroll.contentSize = CGSize(width: suggestions.scroll.frame.width, height: suggestions.scroll.frame.height)
        }
        Settings.shared.venue = nil
        Settings.shared.table = nil
        Firebase.shared.getCheckIns()
        menu.unready()
    }
}
