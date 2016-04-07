//
//  ObjectFraneworkTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 07/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import XCTest
@testable import ReflectFramework

class ObjectFraneworkTest: XCTestCase {
    
    var trace:[String] = []
    
    override func setUp() {
        super.setUp()
        
        Reflect.configuration("", baseNamed: "Tests.db")
        Reflect.settings.log { (SQL:String) in
            self.trace.append(SQL)
        }
        User.unRegister()
        Address.unRegister()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPopulateData() {

        User.register()
        Address.register()
        
        var userList:[User] = []
        var addressList:[Address] = []
        /*
         Save object
         */
        
        trace = []
        for (index, a) in Address.populate().enumerate() {
            a.pin()
            addressList.append(a)
    
            XCTAssertTrue(trace[index] == "INSERT OR REPLACE INTO Address ( createdAt, updatedAt, street, number, state, zip ) VALUES ('\(a.createdAt!.datatypeValue)', '\(a.updatedAt!.datatypeValue)', '\(a.street)', \(a.number), '\(a.state)', \(a.zip))")
        }
        /*
         Save Object
         with sub class of type Address
         */
        trace = []
        for (index, u) in User.populate().enumerate() {
            u.address = addressList[Int(arc4random_uniform(19)) + 1]
            u.pin()
            userList.append(u)
    
            XCTAssertTrue(trace[index] == "INSERT OR REPLACE INTO User ( createdAt, updatedAt, firstName, lastName, age, birthday, gender, email, registerNumber, Address_objectId ) VALUES ('\(u.createdAt!.datatypeValue)', '\(u.updatedAt!.datatypeValue)', '\(u.firstName)', '\(u.lastName!)', \(u.age), '\(u.birthday!.datatypeValue)', '\(u.gender!)', '\(u.email)', \(u.registerNumber), \(u.address.objectId!))")
        }
        
        /*
         Change Object
         ot new age and automatic change to updatedAt
        */
        trace = []
        for (index, u) in userList.enumerate() {
            u.age = Int(arc4random_uniform(90))
            
            let cal = NSCalendar.currentCalendar()
            u.birthday = cal.dateByAddingUnit(.Day, value: -Int(arc4random_uniform(30)), toDate: NSDate(), options: [])
            u.birthday = cal.dateByAddingUnit(.Month, value: -Int(arc4random_uniform(12)), toDate: u.birthday!, options: [])
            u.birthday = cal.dateByAddingUnit(.Year, value: -u.age, toDate: u.birthday!, options: [])
            u.birthday = cal.dateByAddingUnit(.Hour, value: -Int(arc4random_uniform(60)), toDate: u.birthday!, options: [])
            u.birthday = cal.dateByAddingUnit(.Minute, value: -Int(arc4random_uniform(60)), toDate: u.birthday!, options: [])
            u.pin()
            
            XCTAssertTrue(trace[index] == "UPDATE User SET updatedAt = '\(u.updatedAt!.datatypeValue)', firstName = '\(u.firstName)', lastName = '\(u.lastName!)', age = \(u.age), birthday = '\(u.birthday!.datatypeValue)', gender = '\(u.gender!)', email = '\(u.email)', registerNumber = \(u.registerNumber), Address_objectId = \(u.address.objectId!) WHERE objectId = \(u.objectId!)")
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
