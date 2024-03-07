//
//  Firebase.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

class Firebase {
    
    public static let shared = Firebase()
    
    private let picRef = Storage.storage().reference(forURL: "gs://pint-pilot.appspot.com/")
    private let ref: DatabaseReference
    private let storageRef = Storage.storage().reference()
    
    private var uid = "k"
    
    func setUid(_ uid: String){
        self.uid = uid
    }
    
    private init(){
        ref = Database.database().reference()
    }
    
    func createAccount(_ fname: String, _ sname: String){
        ref.child("users/fname/\(uid)").setValue(fname)
        ref.child("users/sname/\(uid)").setValue(sname)
        ref.child("users/dob/\(uid)").setValue("")
        ref.child("users/verified/\(uid)").setValue(false)
    }
    
    func getCheckIns(){
        ref.child("venues/location").observeSingleEvent(of: .value, with: { locations in
            for location in locations.children.allObjects as! [DataSnapshot]{
                if let lat = location.childSnapshot(forPath: "lat").value as? Double{
                    if let lon = location.childSnapshot(forPath: "lon").value as? Double{
                        if (!Settings.shared.venues.contains(where: {$0.uid == location.key})){
                            Settings.shared.venues.append(Venue(location.key, CLLocationCoordinate2D(latitude: lat, longitude: lon)))
                        }
                    }
                }
            }
            if let homeView = Control.shared.homeView{
                homeView.refresh.ready()
                homeView.suggest()
            }
        })
    }
    
    func getVenueInfo(_ view: VenueView){
        ref.child("venues/name/"+view.venue.uid).observeSingleEvent(of: .value, with: { snapshot in
            self.ref.child("venues/town/"+view.venue.uid).observeSingleEvent(of: .value, with: { t in
                self.ref.child("venues/county/"+view.venue.uid).observeSingleEvent(of: .value, with: { c in
                    if let name = snapshot.value as? String{
                        view.venue.name = name
                        view.display()
                    }
                    if let town = t.value as? String{
                        if let county = c.value as? String{
                            view.location.text = "\(town), \(county)"
                        }
                    }
                })
            })
        })
        ref.child("venues/wifi/"+view.venue.uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists(){
                view.wifiAvailable()
            }
        })
        self.getHours(view.venue.uid, view, nil, {
            view.displayOpen()
        })
    }
    
    func getTitle(_ page: PageVenue){
        ref.child("venues/name/\(page.uid)").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? String{
                page.title = value
                Control.shared.update()
            }
        })
    }
    
    func getTables(_ view: ChooseView){
        ref.child("venues/tables/"+view.view.venue.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let tables = snapshot.value as? String{
                var temp = [String]()
                for table in tables.split(separator: ","){
                    temp.append(String(table))
                }
                view.view.venue.tables = temp
                view.showTables()
            }
        })
    }
    
    func getMenu(_ view: VenueView){
        ref.child("venues/menu/"+view.venue.uid).observeSingleEvent(of: .value, with: { snapshot in
            var dict = [String:[String:[String:[String:Int]]]]()
            
            for menu in snapshot.children.allObjects as! [DataSnapshot]{
                var menu_dict = [String:[String:[String:Int]]]()
                
                for submenu in menu.children.allObjects as! [DataSnapshot]{
                    var submenu_dict = [String:[String:Int]]()
                    
                    if submenu.key.replacingOccurrences(of: " ", with: "") != "newmenu"{
                        for item in submenu.children.allObjects as! [DataSnapshot]{
                            var item_dict = [String:Int]()
                            
                            if item.key != "null"{
                                for size in item.children.allObjects as! [DataSnapshot]{
                                    
                                    if let price = size.value as? Int{
                                        item_dict[size.key] = price
                                    }
                                    
                                }
                            }
                            submenu_dict[item.key] = item_dict
                        }
                        menu_dict[submenu.key] = submenu_dict
                    }
                }
                dict[menu.key] = menu_dict
            }
            
            if dict.count > 0{
                view.menu = dict
                
                for item in view.menu!{
                    for sub in item.value{
                        for a in sub.value{
                            for b in a.value{
                                if (b.key.contains("~")){
                                    self.ref.child("venues/menu_desc/\(view.venue.uid)/\(b.key)").observeSingleEvent(of: .value, with: { desc in
                                        if let d = desc.value as? String{
                                            view.menu![item.key]![sub.key]![a.key]![d.lowercased()] = b.value
                                            view.menu![item.key]![sub.key]![a.key]![b.key] = nil
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
            
        })
    }
    
    func upload(image: UIImage, path: String, _ onFinish: @escaping () -> Void) {
        let compressed = image.compress()
        let data = compressed.jpegData(compressionQuality: 0.9)! as NSData
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        if (data.count < Int(1024 * 1024)){
            storageRef.child(path).putData(data as Data, metadata: metaData) { ( data, error ) in
                if let _ = data{
                    onFinish()
                }
            }
        }
    }
    
    func getImage(path: String, image: UIImageView, _ onFinish: @escaping ()->Void){
        picRef.child(path).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let data = data {
                image.image = UIImage(data: data)!
                onFinish()
            }
        }
    }
    
    func getUserInfo(auth: Authentication, on: @escaping ()->Void){
        ref.child("users/fname/\(uid)/").observeSingleEvent(of: .value, with: { [self] first_name in
            self.ref.child("users/sname/\(self.uid)/").observeSingleEvent(of: .value, with: { surname in
                if let f = first_name.value as? String{
                    if let s = surname.value as? String{
                        Authentication.shared.setName("\(f) \(s)")
                        on()
                    }
                }
            })
        })
    }

    func getUserInfo(settings: SettingsView){
        ref.child("users/fname/\(uid)/").observeSingleEvent(of: .value, with: { [self] first_name in
            self.ref.child("users/sname/\(self.uid)/").observeSingleEvent(of: .value, with: { surname in
                self.ref.child("users/dob/\(self.uid)/").observeSingleEvent(of: .value, with: { dob in
                    if let f = first_name.value as? String{
                        settings.fName.text = f
                    }
                    if let s = surname.value as? String{
                        settings.sName.text = s
                    }
                    if let d = dob.value as? String{
                        settings.dob.text = d.toDate()
                    }
                    self.ref.child("users/verified/\(self.uid)/").observeSingleEvent(of: .value, with: { verified in
                        if let v = verified.value as? Bool{
                            if v{
                                settings.verify.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
                                settings.verify.setTitle("verified", for: .normal)
                            }
                            else{
                                settings.picButton.isHidden = false
                            }
                            settings.verify.tag = 100
                        }
                    })
                })
            })
        })
    }
    
    func getCardInfo(){
        ref.child("users/cards/\(uid)/").observeSingleEvent(of: .value, with: { cards in
            for card in (cards.children.allObjects as! [DataSnapshot]){
                if let number = card.childSnapshot(forPath: "number").value as? Int{
                    if let exp_from = card.childSnapshot(forPath: "exp_month").value as? Int{
                        if let exp_to = card.childSnapshot(forPath: "exp_year").value as? Int{
                            if let security = card.childSnapshot(forPath: "security").value as? Int{
                                let new = Card(number: number, exp_month: exp_from, exp_year: exp_to, security: security)
                                if Settings.shared.cards == nil{
                                    Settings.shared.cards = []
                                }
                                Settings.shared.cards?.append(new)
                            }
                        }
                    }
                }
            }
            if let sv = Control.shared.settingsView{
                sv.updateBank()
            }
        })
    }
    
    func placeOrder(){
        let date = Basket.shared.id!
        ref.child("users/been/\(uid)/\(Settings.shared.venue!)/\(date)").setValue(true)
        ref.child("orders/delivered/\(Settings.shared.venue!)/\(uid)/\(date)").setValue(false)
        ref.child("orders/info/\(Settings.shared.venue!)/\(uid)/\(date)/table").setValue(Settings.shared.table!)
        var i = 0
        var pints = 0
        for item in Basket.shared.get(){
            let m = item.menuItem
            
            ref.child("orders/info/\(Settings.shared.venue!)/\(uid)/\(date)/\(m.cat)/\(m.subCat)/\(i)/name").setValue(m.item)
            ref.child("orders/info/\(Settings.shared.venue!)/\(uid)/\(date)/\(m.cat)/\(m.subCat)/\(i)/quantity").setValue(item.quantity)
            ref.child("orders/info/\(Settings.shared.venue!)/\(uid)/\(date)/\(m.cat)/\(m.subCat)/\(i)/price").setValue(m.price)
            if let size = m.size{
                ref.child("orders/info/\(Settings.shared.venue!)/\(uid)/\(date)/\(m.cat)/\(m.subCat)/\(i)/size").setValue(size)
                switch size.lowercased().replacingOccurrences(of: "-", with: " ") {
                case "full pint":
                    pints += 2
                    break
                case "pint":
                    pints += 2
                    break
                case "half pint":
                    pints += 1
                    break
                default:
                    break
                }
            }
            
            i += 1
        }
        
        let split = date.split(separator: ":")
        let today = "\(split[0]):\(split[1]):\(split[2])"
        
        ref.child("scores/\(today)/\(Settings.shared.venue!)/\(self.uid)/").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? Int{
                self.ref.child("scores/\(today)/\(Settings.shared.venue!)/\(self.uid)/").setValue(pints+value)
            }else{
                self.ref.child("scores/\(today)/\(Settings.shared.venue!)/\(self.uid)/").setValue(pints)
            }
        })
    }
    
    func getBoardingPasses(_ view: BoardingPassView){
        
        ref.child("users/been/\(uid)/").observe(.value, with: { snapshot in
            
            for venue in snapshot.children.allObjects as! [DataSnapshot]{
                
                if (!view.venue_title.contains(where: {$0.key == venue.key})){
                    self.ref.child("venues/name/\(venue.key)").observeSingleEvent(of: .value, with: { name in
                        if let n = name.value as? String{
                            view.venue_title[venue.key] = n
                        }
                    })
                }
                
                for pass in venue.children.allObjects as![DataSnapshot]{
                    var bp: BoardingPass?
                    
                    func final(){
                        if let boardingPass = bp{
                            self.ref.child("orders/delivered/\(venue.key)/\(self.uid)/\(pass.key)").observe(.value, with: { delivered in
                                if let value = delivered.value as? Bool{
                                    boardingPass.isDelivered = value
                                }
                                view.display()
                            })
                            self.ref.child("venues/color/\(venue.key)").observeSingleEvent(of: .value, with: { color in
                                if let primary = color.childSnapshot(forPath: "primary").value as? String{
                                    boardingPass.primaryColor = UIColor(hex: "#\(primary)ff")
                                    if let secondary = color.childSnapshot(forPath: "secondary").value as? String{
                                        boardingPass.secondaryColor = UIColor(hex: "#\(secondary)ff")
                                    }
                                    else{
                                        boardingPass.secondaryColor = UIColor(hex: "#ffffffff")
                                    }
                                }
                                else{
                                    boardingPass.primaryColor = UIColor(hex: "#578789ff")
                                }
                                view.display()
                            })
                        }
                    }
                    
                    if let boardingPass = view.passes.first(where: {$0.uid == venue.key && $0.id == pass.key}){
                        bp = boardingPass
                        final()
                    }
                    else{
                        self.ref.child("orders/info/\(venue.key)/\(self.uid)/\(pass.key)/table").observeSingleEvent(of: .value, with: { table in
                            if let value = table.value as? String{
                                bp = self.getBoardingPass(venue.key, pass.key, value, view)
                            }
                            final()
                        })
                    }
                }
            }
            
            view.display()
        })
    }
    
    func getBoardingPass(_ uid: String, _ id: String, _ table: String, _ view: BoardingPassView) -> BoardingPass{
        let new = BoardingPass(uid, id, table)
        ref.child("orders/info/\(uid)/\(self.uid)/\(id)").observeSingleEvent(of: .value, with: { snapshot in
            for menu in snapshot.children.allObjects as! [DataSnapshot]{
                for submenu in menu.children.allObjects as! [DataSnapshot]{
                    for order in submenu.children.allObjects as! [DataSnapshot]{
                        if let key = Int(order.key){
                            if let price = order.childSnapshot(forPath: "price").value as? Int{
                                new.price[key] = price
                            }
                            if let title = order.childSnapshot(forPath: "name").value as? String{
                                new.title[key] = title
                            }
                            if let quantity = order.childSnapshot(forPath: "quantity").value as? Int{
                                new.quantity[key] = quantity
                            }
                            if let extra = order.childSnapshot(forPath: "size").value as? String{
                                new.extra[key] = extra
                            }
                            new.menu[key] = menu.key
                            new.submenu[key] = submenu.key
                        }
                    }
                }
            }
            view.passes.append(new)
            view.display()
        })
        return new
    }
    
    var user = [String:Int]()
    var bar = [String:Int]()
    var town = [String:[String]]()
    var region = [String:[String]]()
    var country = [String:[String]]()
    
    func getScores(_ view: HomeView){
        
        let split = Date.init().get().split(separator: ":")
        let today = "\(split[0]):\(split[1]):\(split[2])"
        let yesterday = Date.init().get().yesterday()
        
        var venues = [String:Int]()
        var users_temp = [String:Int]()
        
        for day in [today,yesterday]{
            var total = 0
            ref.child("scores/\(day)").observe(.value, with: { snapshot in
                
                for venue in snapshot.children.allObjects as! [DataSnapshot]{
                    self.getVenueLocationData(venue.key,view)
                    var score = 0
                    for user in venue.children.allObjects as! [DataSnapshot]{
                        if let value = user.value as? Int{
                            score += value
                            total += value
                            if let old = users_temp[user.key]{
                                users_temp[user.key] = value+old
                            }
                            else{
                                users_temp[user.key] = value
                            }
                        }
                    }
                    venues[venue.key] = score
                }
                
                self.user = users_temp
                self.bar = venues
                
                if total > 0{
                    view.updateScores(true)
                }
                else{
                    view.updateScores(false)
                }
            })
        }
    }
    
    func getVenueLocationData(_ venue: String, _ view: HomeView){
        
        func onFinish(){
            view.updateScores(view.hasScores)
        }
        
        if !self.town.contains(where: {$0.value.contains(venue)}){
            self.ref.child("venues/town/\(venue)").observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? String{
                    if var towns = self.town[value]{
                        towns.append(venue)
                        self.town[value] = towns
                    }
                    else{
                        self.town[value] = [venue]
                    }
                }
                onFinish()
            })
            self.ref.child("venues/county/\(venue)").observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? String{
                    if var towns = self.region[value]{
                        towns.append(venue)
                        self.region[value] = towns
                    }
                    else{
                        self.region[value] = [venue]
                    }
                }
                onFinish()
            })
            self.ref.child("venues/country/\(venue)").observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? String{
                    if var towns = self.country[value]{
                        towns.append(venue)
                        self.country[value] = towns
                    }
                    else{
                        self.country[value] = [venue]
                    }
                }
                onFinish()
            })
        }
    }
    
    func getExtraVenueInfo(_ page: PageVenue){
        if let venueView = page.venueView{
            if venueView.location_string == nil{
                getVenuePageAddress(page)
            }
            if venueView.hours == nil{
                getVenue(page)
            }
            
        }
        
        ref.child("venues/wifi/\(page.uid)/").observeSingleEvent(of: .value, with: { snapshot in
            if let name = snapshot.childSnapshot(forPath: "wifiaddress").value as? String{
                if let password = snapshot.childSnapshot(forPath: "password").value as? String{
                    page.setWifi(name, password)
                }
            }
            else{
                page.setWifi(nil, nil)
            }
        })
        
        ref.child("venues/socials/"+page.uid).observeSingleEvent(of: .value, with: { snapshot in
            var socials = [String: String]()
            for social in snapshot.children.allObjects as! [DataSnapshot]{
                if let value = social.value as? String{
                    socials[social.key] = value
                }
            }
            page.updateSocials(socials)
        })
    }
    
    func getVenue(_ page: PageVenue){
    
        self.getHours(page.uid, page.venueView, page, {})
            
    }
    
    func getHours(_ uid: String, _ view: VenueView?, _ page: PageVenue?, _ onFinish: @escaping () -> Void){
        func getHours(_ d: String, _ snapshot: DataSnapshot) -> Open_Close?{
            
            if let open = snapshot.childSnapshot(forPath: "\(d)/open").value as? String{
                if let closed = snapshot.childSnapshot(forPath: "\(d)/closed").value as? String{
                    return Open_Close(open: open, close: closed)
                }
            }
            return nil
        }
        self.ref.child("venues/hours/\(uid)").observeSingleEvent(of: .value, with: { snapshot in
            
            var collect = [Open_Close]()
            
            for day in Date.weekdays{
                if let val = getHours(day, snapshot){
                    collect.append(val)
                }
            }
            if collect.count > 0{
                let hours = Opening_Hours(monday: collect[0], tuesday: collect[1], wednesday: collect[2], thursday: collect[3], friday: collect[4], saturday: collect[5], sunday: collect[6])
                view?.hours = hours
                page?.display(hours)
                
                onFinish()
            }
        })
    }
    
    func getVenuePageAddress(_ page: PageVenue){
        self.ref.child("venues/addressline1/\(page.uid)").observeSingleEvent(of: .value, with: { a1 in
            self.ref.child("venues/addressline2/\(page.uid)").observeSingleEvent(of: .value, with: { a2 in
                self.ref.child("venues/town/\(page.uid)").observeSingleEvent(of: .value, with: { t in
                    self.ref.child("venues/county/\(page.uid)").observeSingleEvent(of: .value, with: { r in
                        self.ref.child("venues/postcode/\(page.uid)").observeSingleEvent(of: .value, with: { p in
                            if let address1 = a1.value as? String{
                                if let address2 = a2.value as? String{
                                    if let town = t.value as? String{
                                        if let region = r.value as? String{
                                            if let postcode = p.value as? String{
                                                let location = "\(address1), \(address2), \(town), \(region), \(postcode)".replacingOccurrences(of: " ,", with: "")
                                                page.infoLabel.text = location
                                            }
                                        }
                                    }
                                }
                                page.display(nil)
                            }
                        })
                    })
                })
            })
        })
    }
    
    func saveCard(_ new: Card, _ onFinish: @escaping () -> Void){
        
        ref.child("users/cards/\(uid)/").observeSingleEvent(of: .value, with: { snapshot in
            var keys = [String]()
            for card in snapshot.children.allObjects as! [DataSnapshot]{
                keys.append(card.key)
            }
            
            var key = 1
            while keys.contains(String(key)){
                key += 1
            }
            
            self.ref.child("users/cards/\(self.uid)/\(key)/number").setValue(new.number)
            self.ref.child("users/cards/\(self.uid)/\(key)/exp_month").setValue(new.exp_month)
            self.ref.child("users/cards/\(self.uid)/\(key)/exp_year").setValue(new.exp_year)
            self.ref.child("users/cards/\(self.uid)/\(key)/security").setValue(new.security)
            
            onFinish()
        })
        
    }
    
    func deleteCard(_ deleting: Card){
        
        func equals(_ card: DataSnapshot, _ value: String, _ compare: Int) -> Bool{
            if let number = card.childSnapshot(forPath: "number").value as? Int{
                if number == deleting.number{
                    return true
                }
            }
            return false
        }
        
        ref.child("users/cards/\(uid)/").observeSingleEvent(of: .value, with: { snapshot in
            for card in snapshot.children.allObjects as! [DataSnapshot]{
                if  equals(card, "number", deleting.number) &&
                    equals(card, "security", deleting.security) &&
                    equals(card, "exp_from", deleting.exp_month) &&
                    equals(card, "exp_to", deleting.exp_year){
                    self.ref.child("users/cards/\(self.uid)/\(card.key)").setValue(nil)
                    return
                }
            }
        })
    }
    
    func preloadQRCodes(){
        
        ref.child("users/been/\(uid)/").observe(.value, with: { snapshot in
            var count = 0
            for venue in snapshot.children.allObjects as! [DataSnapshot]{
                count += venue.children.allObjects.count
                for visit in venue.children.allObjects as! [DataSnapshot]{
                    let qr = QRGenerator(code: "\(venue.key)/\(self.uid)/\(visit.key)", foreground: UIColor.white.cgColor, background: UIColor.white.cgColor)
                    BoardingPass.qr_codes["\(venue.key)/\(self.uid)/\(visit.key)"] = qr
                }
            }
            
        })
    }
    
}

