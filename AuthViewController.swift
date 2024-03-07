//
//  AuthViewController.swift
//  pint pilot
//
//  Created by Karl Cridland on 29/11/2020.
//

import Foundation
import UIKit

class AuthViewController: UIViewController{
    
    let action = UIButton()
    let back = UIButton()
    
    private let scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    let email = FormTextField("email address")
    let password = FormTextField("password")
    let confirm = FormTextField("confirm")
    
    let first_name = FormTextField("first name")
    let last_name = FormTextField("last name")
    
    override func viewDidLoad() {
        super .viewDidLoad()
        self.view.backgroundColor = .systemGray5
        if let s = Settings.shared.home?.view.superview{
            self.view.layer.cornerRadius = s.layer.cornerRadius
        }
        password.isPassword = true
        confirm.isPassword = true
        view.addSubview(scroll)
        scroll.showsVerticalScrollIndicator = false
        scroll.contentSize = CGSize(width: scroll.frame.width, height: scroll.frame.height+150)
    }
    
    func sign_in(){
        scroll.removeAll()
        addLogo()
        
        email.frame = CGRect(x: 50, y: Settings.shared.upper_bound+120, width: view.frame.width-100, height: 40)
        password.frame = CGRect(x: 50, y: email.frame.maxY+20, width: view.frame.width-100, height: 40)
        
        action.frame = CGRect(x: password.center.x, y: password.frame.maxY+20, width: password.frame.width/2, height: password.frame.height)
        back.frame = CGRect(x: password.frame.minX, y: password.frame.maxY+20, width: password.frame.width/2, height: password.frame.height)
        
        action.setTitle("sign in", for: .normal)
        back.setTitle("back", for: .normal)
        
        action.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        back.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        
        action.addTarget(self, action: #selector(sign_in_clicked), for: .touchUpInside)
        back.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
        email.becomeFirstResponder()
        scroll.addSubview([email,password,back,action])
    }
    
    @objc func sign_in_clicked(){
        if email.validation(email.text!.isEmail()){
            if password.validation(password.text!.isPassword()){
                Authentication.shared.signIn(email.text!.replacingOccurrences(of: " ", with: ""), password.text!,{
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        let _ = password.validation(password.text!.isPassword())
    }
    
    @objc func sign_up_clicked(){
        if first_name.validation(first_name.text!.count>3){
            if last_name.validation(last_name.text!.count>3){
                if email.validation(email.text!.isEmail()){
                    if password.validation(password.text!.isPassword()){
                        if confirm.validation(password.text! == confirm.text!){
                            Authentication.shared.createAccount(email.text!, password.text!, first_name.text!, last_name.text!,{
                                self.remove()
                                if let home = Settings.shared.home{
                                    home.startUp()
                                }
                            })
                        }
                    }
                }
            }
        }
        let _ = last_name.validation(last_name.text!.count>3)
        let _ = email.validation(email.text!.isEmail())
        let _ = password.validation(password.text!.isPassword())
    }
    
    @objc func remove(){
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    func sign_up(){
        scroll.removeAll()
        addLogo()
        
        first_name.frame = CGRect(x: 50, y: Settings.shared.upper_bound+120, width: view.frame.width-100, height: 40)
        last_name.frame = CGRect(x: 50, y: first_name.frame.maxY+20, width: view.frame.width-100, height: 40)
        email.frame = CGRect(x: 50, y: last_name.frame.maxY+20, width: view.frame.width-100, height: 40)
        password.frame = CGRect(x: 50, y: email.frame.maxY+20, width: view.frame.width-100, height: 40)
        confirm.frame = CGRect(x: 50, y: password.frame.maxY+20, width: view.frame.width-100, height: 40)
        
        action.frame = CGRect(x: password.center.x, y: confirm.frame.maxY+20, width: password.frame.width/2, height: password.frame.height)
        back.frame = CGRect(x: password.frame.minX, y: confirm.frame.maxY+20, width: password.frame.width/2, height: password.frame.height)
        
        action.setTitle("sign up", for: .normal)
        back.setTitle("back", for: .normal)
        
        action.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        back.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        
        action.addTarget(self, action: #selector(sign_up_clicked), for: .touchUpInside)
        back.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
        first_name.becomeFirstResponder()
        scroll.addSubview([first_name,last_name,email,password,confirm,back,action])
        
    }
    
    func addLogo(){
        let logo = UIImageView(frame: CGRect(x: view.frame.width/2-50, y: Settings.shared.upper_bound, width: 100, height: 100))
        logo.image = UIImage(named: "logo")
        scroll.addSubview(logo)
    }
    
}

@IBDesignable
class FormTextField: UITextField {
    
    let plc: String
    var isPassword = false
    var isPopulated = false
    
    init(_ placeholder: String) {
        self.plc = placeholder
        super .init(frame: .zero)
        style()
    }
    
    init(frame: CGRect, _ placeholder: String) {
        self.plc = placeholder
        super .init(frame: frame)
        style()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func style(){
        backgroundColor = .systemGray6
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        layer.cornerRadius = 5
        
        addTarget(self, action: #selector(didEnter), for: .editingDidBegin)
        addTarget(self, action: #selector(didType), for: .editingChanged)
        addTarget(self, action: #selector(didLeave), for: .editingDidEnd)
        addTarget(self, action: #selector(resetBorder), for: .allEditingEvents)
        
        text = plc
        textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    @objc func resetBorder(){
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
    }
    
    func validation(_ test: Bool) -> Bool{
        if !test{
            layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).withAlphaComponent(0.6).cgColor
        }
        return test
    }
    
    @objc func didEnter(){
        
        if !isPopulated{
            text = ""
            textColor = .black
        }
        
        if isPassword{
            isSecureTextEntry = true
        }
        
    }
    
    @objc func didType(){
        if text!.count > 0{
            isPopulated = true
        }
    }
    
    @objc func didLeave(){
        
        if text!.count == 0{
            isPopulated = false
            text = plc
            textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
        
        if isPassword && !isPopulated{
            isSecureTextEntry = false
        }
        
    }
    
    @IBInspectable var insetX: CGFloat = 10
    @IBInspectable var insetY: CGFloat = 0

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}
