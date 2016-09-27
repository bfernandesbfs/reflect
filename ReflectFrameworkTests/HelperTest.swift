//
//  HelperTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 08/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

func convertNil<T>(_ obj:T?) -> String {
    if obj == nil {
        return "NULL"
    }
    else if let value = obj as? String {
        return "'\(value)'"
    }
    else if let value = obj as? Date {
        return "'\(value.datatypeValue)'"
    }
    else if let value = obj as? Data {
        return "\(value.datatypeValue)"
    }
    else if let value = obj as? Double {
        return String(value)
    }
    else if let value = obj as? NSInteger {
        return String(value)
    }
    else {
        return String(describing: obj!)
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
        let cal = Calendar.current
        u.birthday = (cal as NSCalendar).date(byAdding: .day, value: -Int(arc4random_uniform(30)), to: Date(), options: [])
        u.birthday = (cal as NSCalendar).date(byAdding: .month, value: -Int(arc4random_uniform(12)), to: u.birthday!, options: [])
        u.birthday = (cal as NSCalendar).date(byAdding: .year, value: -u.age, to: u.birthday!, options: [])
        u.birthday = (cal as NSCalendar).date(byAdding: .hour, value: -Int(arc4random_uniform(60)), to: u.birthday!, options: [])
        u.birthday = (cal as NSCalendar).date(byAdding: .minute, value: -Int(arc4random_uniform(60)), to: u.birthday!, options: [])
        
        u.pin()
        
        userList.append(u)
    }
}

func populateDataFake() {
    addressList = Address.query().findObject()
    userList    = User.query().join(Address.self).findObject()
}

//Operator Overloading Methods
public func >> (lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == ComparisonResult.orderedAscending
}

public func << (lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == ComparisonResult.orderedDescending
}

public func unique<S: Sequence, E: Hashable>(_ source: S) -> [E] where E==S.Iterator.Element {
    var seen: [E:Bool] = [:]
    return source.filter({ (v) -> Bool in
        return seen.updateValue(true, forKey: v) == nil
    })
}
