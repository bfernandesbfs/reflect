//
// HelperTest.swift
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
        u.birthday = cal.date(byAdding: .day, value: -Int(arc4random_uniform(30)), to: Date())
        u.birthday = cal.date(byAdding: .month, value: -Int(arc4random_uniform(12)), to: u.birthday!)
        u.birthday = cal.date(byAdding: .year, value: -u.age, to: u.birthday!)
        u.birthday = cal.date(byAdding: .hour, value: -Int(arc4random_uniform(60)), to: u.birthday!)
        u.birthday = cal.date(byAdding: .minute, value: -Int(arc4random_uniform(60)), to: u.birthday!)
        
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
