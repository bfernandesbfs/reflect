//
// ModelTest.swift
// CoreReflect
//
// Created by Bruno Fernandes on 18/03/16.
// Copyright © 2016 BFS. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

@testable import CoreReflect

class User: Reflect {
    var firstName:String
    var lastName :String?
    var age:Int
    var birthday:Date?
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
            u.email = "\(u.firstName).\(u.lastName!)@test.com".lowercased()
            
            let cal = Calendar.current
            u.birthday = cal.date(byAdding: .day, value: -Int(arc4random_uniform(30)), to: Date())
            u.birthday = cal.date(byAdding: .month, value: -Int(arc4random_uniform(12)), to: u.birthday!)
            u.birthday = cal.date(byAdding: .year, value: -u.age, to: u.birthday!)
            u.birthday = cal.date(byAdding: .hour, value: -Int(arc4random_uniform(60)), to: u.birthday!)
            u.birthday = cal.date(byAdding: .minute, value: -Int(arc4random_uniform(60)), to: u.birthday!)
            
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
    var status:Bool
    
    required init() {
        street = ""
        number = 0
        state  = ""
        zip    = 0
        status = true
    }
    
    override class func ignoredProperties() -> Set<String> {
        return ["status"]
    }
    
    class func populate() -> [Address] {
        
        var results:[Address] = []
        var data:[[String:Any]]!
        
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
        
        
        for d in data {
            let address = Address()
            address.street = d["street"] as! String
            address.number = d["number"] as! Int
            address.state  = d["state"] as! String
            address.zip    = d["zip"] as! Int
            
            results.append(address)
        }
        return results
    }
}

class TestField: Reflect {
    /*
     Data Type support
    */
    var varstring  : String
    var varint     : Int
    var varint8    : Int8
    var varint16   : Int16
    var varint32   : Int32
    var varint64   : Int64
    var varuint    : UInt
    var varuint8   : UInt8
    var varuint16  : UInt16
    var varuint32  : UInt32
    var varuint64  : UInt64
    var varbool    : Bool
    var varfloat   : Float
    var vardouble  : Double
    //Objc
    var varnsstring: NSString
    var vardate    : Date
    var varnumber  : NSNumber
    var vardata    : Data
    
    var status  :Bool
    var register:Int
    var value   :String
    var identifier:String
    
    required init(){
        varstring = "string"
        varint    = 1
        varint8   = 2
        varint16  = 3
        varint32  = 4
        varint64  = 5
        varuint   = 6
        varuint8  = 7
        varuint16 = 8
        varuint32 = 9
        varuint64 = 10
        varbool   = false
        varfloat  = 1.1
        vardouble = 1.2
        varnsstring  = "nsstring"
        vardate   = Date()
        varnumber = 111
        vardata   = String("Test Data").data(using: String.Encoding.utf8)!
        
        status   = false
        register = 0
        value    = ""
        identifier = UUID().uuidString
    }
    
    /**
     Implement this func to change name of class as entity to another selected
     
     - returns: a new name to entity for class
     */
    override class func entityName() -> String {
        return "FieldTest"
    }
    
    /**
     Implement this func to ignore property when the Reflect Object create an Table on Data Base
     
     - returns: List to ignore properties
     */
    override class func ignoredProperties() -> Set<String> {
        return ["status", "register", "value"]
    }
    
    /**
     Generate value to sample
     
     - parameter index: index of list
     */
    func generateValue(_ index:Int) {
        let i  = index * 10
        varstring = "string \(index)"
        varint    = 1 * i
        varint8   = 2 + Int8(arc4random_uniform(125))
        varint16  = 3 + Int16(varint8)
        varint32  = 4 + Int32(varint16)
        varint64  = 5 + Int64(varint32)
        varuint   = 6 + UInt(i)
        varuint8  = 7 + UInt8(varuint)
        varuint16 = 8 + UInt16(varuint8)
        varuint32 = 9 + UInt32(varuint16)
        varuint64 = 10 + UInt64(varuint32)
        varbool   = arc4random_uniform(2) == 1
        varfloat  = 1.1 * Float(i / 2)
        vardouble = 1.2 * Double(i / 10)
        varnsstring  = "nsstring \(index)" as NSString
        vardate   = Date()
        varnumber = 111.0 //* vardouble
        vardata   = String("Test Data Number \(index) ").data(using: String.Encoding.utf8)!
        
        status   = arc4random_uniform(2) == 1
        register = index + 15
        value    = "value \(index)"
        identifier = UUID().uuidString
    }
}

class TestFieldOptional: Reflect {
    /*
     Data Type optionls support
     */
    var optionalString   : String?
    var optionalNSString : NSString?
    var optionalNSInteger: NSInteger?
    var optionalDate     : Date?
    var optionalNumber   : NSNumber?
    var optionalData     : Data?
    
    required init() {
    }
    
    /**
     Generate value to sample
     
     - parameter index: index of list
     */
    func generateValue(_ index:Int) {
        let i  = index * 10
        
        if Int(arc4random_uniform(1000)) % 2 == 0 {
            optionalString    = "String \(index)"
        }
        
        if Int(arc4random_uniform(1000)) % 2 == 0 {
            optionalNSString  = "NSString \(index)" as NSString?
        }
        
        if Int(arc4random_uniform(1000)) % 2 == 0 {
            optionalNSInteger = 2 + i
        }
        
        if Int(arc4random_uniform(1000)) % 2 == 0 {
            optionalDate   = Date()
        }
        
        if Int(arc4random_uniform(1000)) % 2 == 0 {
            optionalNumber = NSNumber(value: 111.43 * Double(i))
        }
        
        if Int(arc4random_uniform(100)) % 2 == 0 {
            optionalData   = String("Test Data Optional Number \(index) ").data(using: String.Encoding.utf8)!
        }
    }
}
