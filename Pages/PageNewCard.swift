//
//  PageNewCard.swift
//  pint pilot
//
//  Created by Karl Cridland on 25/11/2020.
//

import Foundation
import UIKit

class PageNewCard: Page{
    
    private let form = UIView()
    private let saved = UIView()
    
    private let card_number = CardTextField("card number")
    private let expiration = CardTextField("exp mm/yy")
    private let security_cvc = CardTextField("cvc")
    
    private var save = UIButton()
    
    private var valid = false
    
    init() {
        super .init(title: "Manage Cards")
        
        form.frame = CGRect(x: 50, y: 20, width: frame.width-100, height: 100)
        
        let new_card = SView(title: "new card")
        form.addSubview(new_card)
        new_card.update()
        card_number.frame = CGRect(     x: 0,                          y: 50,                          width: form.frame.width,                height: 40)
        expiration.frame = CGRect(      x: 0,                          y: card_number.frame.maxY+10,   width: 3*card_number.frame.width/5-10,  height: 40)
        security_cvc.frame = CGRect(    x: expiration.frame.maxX+20,   y: expiration.frame.minY,       width: 2*card_number.frame.width/5-10,  height: 40)
        
        card_number.tag = 19
        expiration.tag = 7
        security_cvc.tag = 3
        
        card_number.nextField = expiration
        expiration.nextField = security_cvc
        
        card_number.addTarget(self, action: #selector(editCard), for: .allEditingEvents)
        expiration.addTarget(self, action: #selector(expCheck), for: .allEditingEvents)
        security_cvc.addTarget(self, action: #selector(cvcCheck), for: .allEditingEvents)
        
        let fields = [card_number,expiration,security_cvc]
        
        for field in fields{
            field.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            field.keyboardType = .numberPad
            field.textAlignment = .center
            field.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
            field.backgroundColor = .systemGray6
            field.layer.borderWidth = 2
            field.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
            field.layer.cornerRadius = 5
            field.others = fields
            
            field.addTarget(self, action: #selector(validateCards), for: .allEditingEvents)
        }
        
        save = UIButton(frame: CGRect(x: (form.frame.width/2)-50, y: security_cvc.frame.maxY+25, width: 100, height: 30))
        save.addTarget(self, action: #selector(saveCard), for: .touchUpInside)
        save.setTitle("save", for: .normal)
        save.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        save.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        save.backgroundColor = .systemGray6
        save.layer.borderWidth = 2
        save.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        save.layer.cornerRadius = 5
        save.alpha = 0.6
        form.addSubview(save)
        
        form.frame = CGRect(x: form.frame.minX, y: form.frame.minY, width: form.frame.width, height: save.frame.maxY+20)
        saved.frame = CGRect(x: form.frame.minX, y: form.frame.maxY, width: form.frame.width, height: 100)
        
        displayCards()
        
        view.addSubview([form,saved])
        form.addSubview([card_number,expiration,security_cvc])
    }
    
    func displayCards(){
        saved.removeAll()
        
        let saved_cards = SView(title: "saved cards")
        saved.addSubview(saved_cards)
        saved_cards.update()
        
        if let cards = Settings.shared.cards{
            var i = 0
            for card in cards{
                let background = UIView(frame: CGRect(x: 0, y: 50+CGFloat(i)*50, width: saved.frame.width, height: 40))
                background.backgroundColor = .systemGray6
                background.layer.borderWidth = 2
                background.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
                background.layer.cornerRadius = 5
                
                let label = UILabel(frame: CGRect(x: 10, y: 0, width: saved.frame.width-110, height: background.frame.height))
                label.text = String(card.number).blurCard()
                label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
                
                let delete = UIButton(frame: CGRect(x: saved.frame.width-120, y: label.frame.minY, width: 100, height: label.frame.height))
                delete.addTarget(self, action: #selector(deleteCard), for: .touchUpInside)
                delete.setTitle("delete", for: .normal)
                delete.contentHorizontalAlignment = .right
                delete.setTitleColor(#colorLiteral(red: 0.899213399, green: 0.1491314173, blue: 0, alpha: 1), for: .normal)
                delete.alpha = 0.8
                delete.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
                delete.accessibilityElements = [card]
                
                background.addSubview([label,delete])
                saved.addSubview(background)
                i += 1
                
                saved.frame = CGRect(x: saved.frame.minX, y: saved.frame.minY, width: saved.frame.width, height: background.frame.maxY+40)
            }
            
            view.contentSize = CGSize(width: view.frame.width, height: saved.frame.maxY)
        }
    }
    
    @objc func saveCard(){
        if valid{
            if let number = Int(card_number.text!.replacingOccurrences(of: " ", with: "")){
                if let exp_month = Int(expiration.text!.replacingOccurrences(of: " ", with: "").split(separator: "/")[0]){
                    if let exp_to = Int(expiration.text!.replacingOccurrences(of: " ", with: "").split(separator: "/")[1]){
                        if let cvc = Int(security_cvc.text!){
                            let card = Card(number: number, exp_month: exp_month, exp_year: exp_to, security: cvc)
                            
                            if let cards = Settings.shared.cards{
                                if cards.contains(where: {$0 == card}){
                                    print("Nope")
                                    return
                                }
                            }
                            Firebase.shared.saveCard(card,{
                                for field in [self.card_number,self.expiration,self.security_cvc]{
                                    field.text = ""
                                }
                                self.resignFields()
                                if let _ = Settings.shared.cards{
                                    Settings.shared.cards?.append(card)
                                }
                                else{
                                    Settings.shared.cards = [card]
                                }
                                self.displayCards()
                            })
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc func deleteCard(_ sender: UIButton){
        print("trying")
        if let card = sender.accessibilityElements?[0] as? Card{
            print("should work")
            Firebase.shared.deleteCard(card)
            Settings.shared.removeCard(card)
            displayCards()
        }
    }
    
    func resignFields(){
        for field in [card_number,expiration,security_cvc]{
            field.didLeave()
            field.resignFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFields()
    }
    
    @objc func validateCards(_ sender: CardTextField){
        valid = isValid(fields: [card_number,expiration,security_cvc])
        if valid{
            save.alpha = 1
        }
        else{
            save.alpha = 0.6
        }
    }
    
    func isValid(fields: [CardTextField]) -> Bool{
        for field in fields{
            if !(field.isPopulated && field.text!.count == field.tag){
                return false
            }
        }
        return true
    }
    
    @objc func expCheck(sender: CardTextField){
        if sender.isPopulated{
            sender.text = sender.text?.expiry_validation(sender.accessibilityLabel)
            while true{
                if let slash = sender.text?.last{
                    if (String(slash) == "/") || (String(slash) == " "){
                        sender.text?.removeLast()
                    }
                    else{
                        break
                    }
                }
                else{
                    break
                }
            }
            sender.accessibilityLabel = sender.text
        }
    }
    
    @objc func cvcCheck(sender: CardTextField){
        if sender.isPopulated{
            sender.text = sender.text?.cvc_validation()
        }
    }
    
    @objc func editCard(sender: CardTextField){
        if !sender.isPopulated{
            return
        }
        if let selectedRange = sender.selectedTextRange {
            var cursorPosition = sender.offset(from: sender.beginningOfDocument, to: selectedRange.start)
            
            sender.text = sender.text!.cardSpacing()
            
            if sender.text!.count > 0{
                if let c = sender.text!.last{
                    if String(c) == " "{
                        cursorPosition += 1
                    }
                    else{
                        let buf = String(c)
                        sender.text?.removeLast()
                        if let d = sender.text!.last{
                            if String(d) == " "{
                                cursorPosition += 2
                            }
                        }
                        sender.text = sender.text!+buf
                    }
                }
            }
            
            if let space = sender.text!.last{
                if String(space) == " "{
                    sender.text?.removeLast()
                    
                }
            }
            
            let arbitraryValue: Int = cursorPosition
            if let newPosition = sender.position(from: sender.beginningOfDocument, offset: arbitraryValue) {
                sender.selectedTextRange = sender.textRange(from: newPosition, to: newPosition)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CardTextField: UITextField{
    
    var isPopulated = false
    let plc: String
    var nextField: CardTextField?
    
    var others = [CardTextField]()
    
    init(_ placeholder: String) {
        self.plc = placeholder
        super .init(frame: .zero)
        
        addTarget(self, action: #selector(didEnter), for: .editingDidBegin)
        addTarget(self, action: #selector(didType), for: .editingChanged)
        addTarget(self, action: #selector(didLeave), for: .editingDidEnd)
        
        text = plc
        textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    @objc func didEnter(){
        if !isPopulated{
            text = ""
            textColor = .black
        }
        
    }
    
    @objc func didType(){
        if text!.count > 0{
            isPopulated = true
        }
        if text!.count == tag{
            if let field = nextField{
                field.becomeFirstResponder()
            }
            else{
                resignFirstResponder()
            }
        }
    }
    
    @objc func didLeave(){
        
        if text!.count == 0{
            isPopulated = false
            text = plc
            textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
