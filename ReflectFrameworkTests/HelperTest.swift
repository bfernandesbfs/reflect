//
//  HelperTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 08/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

func convertNil<T>(obj:T?) -> String {
    if obj == nil {
        return "NULL"
    }
    else if let value = obj as? String {
        return "'\(value)'"
    }
    else if let value = obj as? NSDate {
        return "'\(value.datatypeValue)'"
    }
    else if let value = obj as? NSData {
        return "\(value.datatypeValue)"
    }
    else if let value = obj as? Double {
        return String(value)
    }
    else if let value = obj as? NSInteger {
        return String(value)
    }
    else {
        return String(obj!)
    }
}

var addressList:[Address] = []
var userList:[User] = []
func populateData() {
    
    User.register()
    Address.register()

    for a in Address.populate() {
        a.pin()
        addressList.append(a)
    }

    for u in User.populate() {
        u.address = addressList[Int(arc4random_uniform(19)) + 1]
        
        u.age = Int(arc4random_uniform(90))
        let cal = NSCalendar.currentCalendar()
        u.birthday = cal.dateByAddingUnit(.Day, value: -Int(arc4random_uniform(30)), toDate: NSDate(), options: [])
        u.birthday = cal.dateByAddingUnit(.Month, value: -Int(arc4random_uniform(12)), toDate: u.birthday!, options: [])
        u.birthday = cal.dateByAddingUnit(.Year, value: -u.age, toDate: u.birthday!, options: [])
        u.birthday = cal.dateByAddingUnit(.Hour, value: -Int(arc4random_uniform(60)), toDate: u.birthday!, options: [])
        u.birthday = cal.dateByAddingUnit(.Minute, value: -Int(arc4random_uniform(60)), toDate: u.birthday!, options: [])
        
        u.pin()
        
        userList.append(u)
    }
}

func populateDataFake() {
    addressList = Address.query().findObject()
    userList    = User.query().findObject()
}

//Operator Overloading Methods
func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedDescending
}
