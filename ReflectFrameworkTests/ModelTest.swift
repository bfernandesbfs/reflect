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
    
    var address: Address
    
    required init() {
        firstName = ""
        age       = 0
        email     = ""
        registerNumber = 0
        address = Address()
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

class Address: Reflect {
    var street:String
    var number :Int
    var state:String
    var zip:Int
    var User_objectId:NSNumber
    
    required init() {
        street = ""
        number = 0
        state  = ""
        zip    = 0
        User_objectId   = 0
    }
    
    class func getAddress(index:Int) -> Address {
        
        var data:[[String:AnyObject]]!
        
        data = [["number": 226, "street": "Highland Drive Temple Hills", "state": "MD", "zip": 20748],
                ["number": 584, "street": "Union Street Detroit", "state": "MI", "zip": 48205],
                ["number": 486, "street": "Homestead Drive Arlington Heights", "state": "IL", "zip": 60004],
                ["number": 988, "street": "Pin Oak Drive Ottumwa", "state": "IA", "zip": 52501],
                ["number": 533, "street": "Monroe Street Biloxi", "state": "MS", "zip": 39532],
                ["number": 760, "street": "2nd Street West Waukesha", "state": "WI", "zip": 53186],
                ["number": 668, "street": "12th Street Lititz", "state": "PA", "zip": 17543],
                ["number": 752, "street": "Pennsylvania Avenue Rossville", "state": "GA", "zip": 30741],
                ["number": 728, "street": "Orchard Street Hagerstown", "state": "MD", "zip": 21740],
                ["number": 128, "street": "Sycamore Drive Gulfport", "state": "MS", "zip": 39503],
                ["number": 640, "street": "10th Street East Lansing", "state": "MI", "zip": 48823],
                ["number": 721, "street": "Willow Avenue Warren", "state": "MI", "zip": 48089],
                ["number": 953, "street": "Brown Street Grand Haven", "state": "MI", "zip": 49417],
                ["number": 803, "street": "Main Street Riverdale", "state": "GA", "zip": 30274],
                ["number": 829, "street": "1st Street Winter Garden", "state": "FL", "zip": 34787],
                ["number": 768, "street": "Willow Lane Norristown", "state": "PA", "zip": 19401],
                ["number": 105, "street": "Route 64 Fairfield", "state": "CT", "zip": 06824],
                ["number": 659, "street": "Ridge Avenue Chattanooga", "state": "TN", "zip": 37421],
                ["number": 995, "street": "11th Street Lombard", "state": "IL","zip": 60148],
                ["number": 525, "street": "Park Street Fairmont", "state": "WV", "zip": 26554]]
        
        
        let address = Address()
        
        let d = data[index]
        
        address.street = d["street"] as! String
        address.number = d["number"] as! Int
        address.state  = d["state"] as! String
        address.zip    = d["zip"] as! Int
        
        return address
    }
}