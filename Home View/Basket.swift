//
//  Basket.swift
//  pint pilot
//
//  Created by Karl Cridland on 25/11/2020.
//

import Foundation

class Basket {
    
    public static let shared = Basket()
    
    var id: String?
    
    private var items = [BasketPush]()
    
    private init(){}
    
    func append(_ new_item: BasketPush){
        for item in items{
            if (item.menuItem.item == new_item.menuItem.item) && (item.menuItem.cat == new_item.menuItem.cat) && (item.menuItem.subCat == new_item.menuItem.subCat){
                if let size = item.menuItem.size{
                    if let new_size = new_item.menuItem.size{
                        if (size == new_size){
                            item.quantity += new_item.quantity
                            return
                        }
                    }
                }
                else{
                    item.quantity += new_item.quantity
                    return
                }
            }
        }
        items.append(new_item)
        
        id = Date.init().get()
    }
    
    func getTotal() -> Int {
        var total = 0
        for item in items{
            total += item.quantity * item.menuItem.price
        }
        return total
    }
    
    func empty(){
        items = []
        id = nil
    }
    
    func removeEmpties(){
        var temp = [BasketPush]()
        for item in items{
            if (item.quantity > 0){
                temp.append(item)
            }
        }
        items = temp
    }
    
    func get() -> [BasketPush]{
        return items
    }
    
}
