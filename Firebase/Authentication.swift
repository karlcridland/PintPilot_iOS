//
//  Authentication.swift
//  pint pilot
//
//  Created by Karl Cridland on 29/11/2020.
//

import Foundation
import FirebaseAuth

class Authentication {
    
    public static let shared = Authentication()
    private var name: String?
    
    private init(){
    }
    
    func get() -> String?{
        if let current = Auth.auth().currentUser{
            return current.uid
        }
        return nil
    }
    
    func email() -> String?{
        if let current = Auth.auth().currentUser{
            return current.email
        }
        return nil
    }
    
    func setName(on: @escaping ()->Void) {
        Firebase.shared.getUserInfo(auth: self) {
            on()
        }
    }
    
    func setName(_ name: String){
        self.name = name
    }
    
    func getName() -> String{
        return name!
    }
    
    func isSignedIn() -> Bool{
        if let current = Auth.auth().currentUser{
            Firebase.shared.setUid(current.uid)
            return true
        }
        return false
    }
    
    func signIn(_ email: String, _ password: String, _ finish: @escaping ()->Void){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print(error)
                return
            }
            if let result = result{
                print(2,result.user)
            }
            if let home = Settings.shared.home{
                home.startUp()
                finish()
            }
        }
    }
    
    func createAccount(_ email: String, _ password: String, _ fname: String, _ sname: String, _ finish: @escaping ()->Void){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let _ = error{
                
                // Callback if error in set up, probably email taken
                
            }
            else{
                if let user = Auth.auth().currentUser {
                    Firebase.shared.setUid(user.uid)
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = "\(fname) \(sname)"
                    changeRequest.commitChanges { _ in
                    }
                    Firebase.shared.createAccount(fname, sname)
                    finish()
                }
            }
        }
    }
    
    func signOut(finish: @escaping ()->Void){
        do{
            try Auth.auth().signOut()
            UIApplication.shared.applicationIconBadgeNumber = 0
            Control.shared.settingsView = nil
            Control.shared.boardingView = nil
            Control.shared.homeView = nil
            Settings.shared.home?.startUp()
        }
        catch{
//            print()
        }
    }
    
}
