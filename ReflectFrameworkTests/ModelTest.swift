//
//  ModelTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 31/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

@testable import ReflectFramework

class User: Reflect {
    var firstName:String
    var lastName :String?
    var age:Int
    var birthday:NSDate?
    var gender:String?
    var email:String
    var registerNumber:Int
    
    required init() {
        firstName = ""
        age       = 0
        email     = ""
        registerNumber = 0
    }
    
    class func populate() -> [User] {
        
        var users:[User] = []
        var data:[[String:String]]!
        
        data = [["first":"Kanisha", "last":"Classen", "gender":"female"],
                ["first":"Doloris", "last":"Vanmeter", "gender":"female"],
                ["first":"Celsa", "last":"Stowers", "gender":"female"],
                ["first":"Noemi", "last":"Pickard", "gender":"female"],
                ["first":"Nakisha", "last":"Kish", "gender":"female"],
                ["first":"Delinda", "last":"Hullinger", "gender":"female"],
                ["first":"Margret", "last":"Freeze", "gender":"female"],
                ["first":"Ammie", "last":"Willie", "gender":"female"],
                ["first":"Angelic", "last":"Zych", "gender":"female"],
                ["first":"Laquanda", "last":"Peugh", "gender":"female"],
                ["first":"Ida", "last":"Fager", "gender":"female"],
                ["first":"Bertram", "last":"Kellar", "gender":"male"],
                ["first":"Florentina", "last":"Engebretson", "gender":"female"],
                ["first":"Pa", "last":"Spurgeon", "gender":"female"],
                ["first":"Dania", "last":"Defenbaugh", "gender":"female"],
                ["first":"Cleora", "last":"Meidinger", "gender":"female"],
                ["first":"Merlene", "last":"Caggiano", "gender":"female"],
                ["first":"Mohamed", "last":"Bausch", "gender":"male"],
                ["first":"Aracelis", "last":"Nickles", "gender":"female"],
                ["first":"Charlie", "last":"Mcclung", "gender":"male"]]
        
        for d in data {
            let u = User()
            u.firstName = d["first"]!
            u.lastName = d["last"]!
            u.gender = d["gender"]
            u.age = Int(arc4random_uniform(100))
            u.registerNumber = u.age * Int(arc4random_uniform(999))
            u.email = "\(u.firstName).\(u.lastName!)@test.com".lowercaseString
            
            let cal = NSCalendar.currentCalendar()
            u.birthday = cal.dateByAddingUnit(.Day, value: -Int(arc4random_uniform(30)), toDate: NSDate(), options: [])
            u.birthday = cal.dateByAddingUnit(.Month, value: -Int(arc4random_uniform(12)), toDate: u.birthday!, options: [])
            u.birthday = cal.dateByAddingUnit(.Year, value: -u.age, toDate: u.birthday!, options: [])
            u.birthday = cal.dateByAddingUnit(.Hour, value: -Int(arc4random_uniform(60)), toDate: u.birthday!, options: [])
            u.birthday = cal.dateByAddingUnit(.Minute, value: -Int(arc4random_uniform(60)), toDate: u.birthday!, options: [])
            
            users.append(u)

        }
        
        return users
    }
}