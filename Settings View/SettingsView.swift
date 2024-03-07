//
//  SettingsView.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import Foundation
import UIKit
import FirebaseAuth

class SettingsView: ControlView {
    
    let save = UIButton()
    let sign_out = UIButton()
    let verify = UIButton()
    
    let personal = SView(title: "passenger info")
    let banking = SView(title: "banking")
    let legal = SView(title: "legal")
    
    let fName = TextField()
    let sName = TextField()
    let dob = TextField()
    let pic = UIImageView()
    let picButton = UIButton()
    
    private var original_image: UIImage?
    
    func name() -> String {
        return fName.text! + " " + sName.text!
    }
    
    override init() {
        super.init()
        
        Firebase.shared.getUserInfo(settings: self)
        
        let width = (frame.width-190)/2
        save.frame = CGRect(x: 20, y: 20, width: width, height: 40)
        sign_out.frame = CGRect(x: frame.width-width-20, y: 20, width: width, height: 40)
        
        sign_out.setTitle("sign out", for: .normal)
        sign_out.setTitleColor(#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), for: .normal)
        sign_out.addTarget(self, action: #selector(signOutClicked), for: .touchUpInside)
        
        save.setTitle("save", for: .normal)
        save.addTarget(self, action: #selector(savePic), for: .touchUpInside)
        save.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        save.backgroundColor = .systemGray5
        save.isHidden = true
        
        verify.frame = save.frame
        verify.setTitle("verify", for: .normal)
        verify.setTitleColor(#colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1), for: .normal)
        verify.addTarget(self, action: #selector(verifyClicked), for: .touchUpInside)
        
        for button in [save,sign_out,verify]{
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.4))
        }
        
        personal.frame = CGRect(x: 0, y: 80, width: frame.width, height: 250)
        
        fName.frame = CGRect(x: 20, y: 70, width: frame.width/2-30, height: 30)
        sName.frame = CGRect(x: 20, y: 140, width: frame.width/2-30, height: 30)
        dob.frame = CGRect(x: 20, y: 210, width: frame.width/2-30, height: 30)
        
        pic.frame = CGRect(x: frame.width/2+10, y: 40, width: frame.width/2-30, height: 200)
        pic.contentMode = .scaleAspectFill
        pic.clipsToBounds = true
        if let uid = Auth.auth().currentUser?.uid{
            pic.getImage(path: "users/profile/\(uid)", {
                self.original_image = self.pic.image
            })
        }
        pic.layer.cornerRadius = 4
        picButton.frame = pic.frame
        picButton.addTarget(self, action: #selector(setImage), for: .touchUpInside)
        picButton.isHidden = true
        
        for name in [fName,sName,dob]{
            name.isUserInteractionEnabled = false
            name.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            name.layer.borderWidth = 1
            name.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            name.layer.cornerRadius = 4
            name.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        }
        
        var i = 0
        for title in ["first name:", "surname:", "date of birth:"]{
            let label = UILabel(frame: CGRect(x: 20, y: 35+CGFloat(i)*70, width: frame.width/2-40, height: 30))
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.4))
            label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            label.text = title
            personal.addSubview(label)
            i += 1
        }
        
        picButton.layer.borderWidth = 1
        picButton.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        picButton.layer.cornerRadius = 4
        picButton.isUserInteractionEnabled = true
        picButton.backgroundColor = .clear
        
        banking.frame = CGRect(x: 0, y: personal.frame.maxY+40, width: frame.width, height: 120)
        banking.update()
        
        legal.frame = CGRect(x: 0, y: banking.frame.maxY+10, width: frame.width, height: 200)
        legal.update()
        
        contentSize = CGSize(width: frame.width, height: legal.frame.maxY)
        
        setUpBanking()
        setUpLegal()
        
        addSubview([personal,banking,verify,legal,save,sign_out])
        personal.addSubview([fName,sName,dob,pic,picButton])
        
        personal.update()
    }
    
    func resetPic(){
        if let original = original_image{
            pic.image = original
            save.isHidden = true
        }
    }
    
    @objc func addNewCard(){
        let _ = PageNewCard()
    }
    
    @objc func signOutClicked(){
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "no", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "yes", style: .default, handler: {_ in
            Authentication.shared.signOut{
                
            }
        }))
        if let home = Settings.shared.home{
            home.present(alert, animated: true)
        }
    }
    
    @objc func verifyClicked(sender: UIButton){
        if (sender.tag == 100){
            if (verify.titleLabel?.text == "verified"){
                let alert = UIAlertController(title: "User Verification", message: "The verification process matches an account to the profile picture they have provided, it does not verify their date of birth.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "continue", style: .default, handler: nil))
                if let home = Settings.shared.home{
                    home.present(alert, animated: true)
                }
            }
            else{
                let _ = PageVerify()
            }
        }
    }
    
    func updateBank(){
        if let m = Settings.shared.getBanking(){
            let b = UIButton()
            b.accessibilityLabel = m
            updateBanking(sender: b)
        }
    }
    
    @objc func updateBanking(sender: UIButton){
        Settings.shared.banking(sender.accessibilityLabel!)
        
        switch sender.accessibilityLabel! {
        case "apple_pay":
            updateBankingHeight(height: 120)
            addPaymentMethod.isHidden = true
            addPaymentMethod.frame = CGRect(x: 0, y: banking.frame.height-35, width: self.banking.frame.width, height: 30)
            break
        case "credit_debit_card":
            if let cards = Settings.shared.cards{
                for subview in banking.subviews{
                    if let ib = subview as? InputButton{
                        if (ib.titleLabel!.text!.contains("*")){
                            subview.removeFromSuperview()
                        }
                    }
                }
                updateBankingHeight(height: CGFloat(160+(40*cards.count)))
                var buttons = [InputButton]()
                var i = 0
                for card in cards{
                    let button = InputButton(frame: CGRect(x: 60, y: CGFloat(i)*40+120, width: banking.frame.width-80, height: 30), value: String(card.number).blurCard(), color: .black)
                    button.addTarget(self, action: #selector(updateCard), for: .touchUpInside)
                    button.t(i)
                    
                    buttons.append(button)
                    banking.addSubview(button)
                    
                    if let saved = Settings.shared.getCard(){
                        if saved == i{
                            button.isChecked = true
                            button.display()
                        }
                    }
                    
                    i += 1
                }
                for button in buttons{
                    button.range = buttons
                }
            }
            else{
                updateBankingHeight(height: 160)
            }
            addPaymentMethod.isHidden = false
            
            
            break
        default:
            break
        }
        
    }
    
    @objc func updateCard(_ sender: UIButton){
        Settings.shared.card(sender.tag)
    }
    
    private func updateBankingHeight(height: CGFloat){
        UIView.animate(withDuration: 0.2, animations: {
            self.banking.frame = CGRect(x: self.banking.frame.minX, y: self.banking.frame.minY, width: self.banking.frame.width, height: height)
            self.legal.frame = CGRect(x: 0, y: self.banking.frame.maxY+40, width: self.frame.width, height: self.legal.frame.height)
            self.contentSize = CGSize(width: self.frame.width, height: self.legal.frame.maxY)
            self.addPaymentMethod.frame = CGRect(x: 0, y: self.banking.frame.height-35, width: self.banking.frame.width, height: 30)
        })
    }
    
    private let lengths = ["apple_pay":CGFloat(148),"credit_debit_card":CGFloat(205)]
    private var addPaymentMethod = UIButton()
    
    func setUpBanking(){
        banking.clipsToBounds = true
        var buttons = [InputButton]()
        var i = 0
//        for type in ["Credit/Debit Card"]{
        for type in ["Apple Pay", "Credit/Debit Card"]{
            let method = type.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "/", with: "_")
            let button = InputButton(frame: CGRect(x: 20, y: 40+CGFloat(i)*40, width: frame.width-40, height: 30), value: type, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
            button.addTarget(self, action: #selector(updateBanking), for: .touchUpInside)
            button.access(method)
            buttons.append(button)
            
            let image = UIImageView(image: UIImage(named: method)!)
            image.frame = CGRect(x: frame.width-55, y: button.frame.minY, width: 30, height: 30)
//            image.frame = CGRect(x: lengths[method]!, y: button.frame.minY, width: 30, height: 30)
            image.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            banking.addSubview(image)
            
            banking.addSubview(button)
            i += 1
            
            if let m = Settings.shared.getBanking(){
                if method == m{
                    button.isChecked = true
                    button.display()
                    updateBanking(sender: button)
                }
            }
        }
        
        for button in buttons{
            button.range = buttons
        }
        
        addPaymentMethod.setTitle("manage cards", for: .normal)
        addPaymentMethod.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        addPaymentMethod.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(0.3))
        addPaymentMethod.addTarget(self, action: #selector(addNewCard), for: .touchUpInside)
        banking.addSubview(addPaymentMethod)
    }
    
    @objc func savePic(){
        if let uid = Auth.auth().currentUser?.uid{
            Firebase.shared.upload(image: pic.image!, path: "users/profile/"+uid, {
                self.save.isHidden = true
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for a in [fName,sName,dob]{
            a.resignFirstResponder()
        }
    }
    
    func setUpLegal() {
        let legalExpanded = [legalStruct(title: "terms & conditions", website: "https://pintpilot.com/termsandconditions"),legalStruct(title: "privacy policy", website: "https://pintpilot.com/privacypolicy")]
        
        for i in 0 ... 1{
            let button = LegalButton(frame: CGRect(x: 10, y: CGFloat(i)*40+40, width: legal.frame.width-20, height: 30), info: legalExpanded[i])
            let www = UIImageView(image: UIImage(named: "www"))
            www.frame = CGRect(x: legal.frame.width-55, y: CGFloat(i)*40+40, width: 30, height: 30)
            www.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            legal.addSubview([www,button])
        }
        
        legal.frame = CGRect(x: legal.frame.minX, y: legal.frame.minY, width: legal.frame.width, height: 140)
        contentSize = CGSize(width: frame.width, height: legal.frame.maxY)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setImage(){
        if let home = Settings.shared.home{
            home.openImagePicker(pic, self)
        }
    }
}
