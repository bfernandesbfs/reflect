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
        
        var initializeLog: Bool = false
        Reflect.configuration("", baseNamed: "Tests.db")
        Reflect.settings.log { (SQL:String) in
            if !initializeLog {
                initializeLog = true
                print("\n Path data base -- ", SQL, "\n")
            }
            else {
                self.trace.append(SQL)
            }
        }
    
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
        for (index, a) in Address.populate().enumerated() {
            a.pin()
            addressList.append(a)
            

            XCTAssertTrue(trace[index] == "INSERT INTO Address ( createdAt, updatedAt, street, number, state, zip ) VALUES ('\(a.createdAt!.datatypeValue)', '\(a.updatedAt!.datatypeValue)', '\(a.street)', \(a.number), '\(a.state)', \(a.zip))", "it isn't compatible")
        }
        /*
         Save Object
         with sub class of type Address
         */
        trace = []
        for (index, u) in User.populate().enumerated() {
            u.address = addressList[Int(arc4random_uniform(19)) + 1]
            u.pin()
            userList.append(u)
    
            XCTAssertTrue(trace[index] == "INSERT INTO User ( createdAt, updatedAt, firstName, lastName, age, birthday, gender, email, registerNumber, Address_objectId ) VALUES ('\(u.createdAt!.datatypeValue)', '\(u.updatedAt!.datatypeValue)', '\(u.firstName)', '\(u.lastName!)', \(u.age), '\(u.birthday!.datatypeValue)', '\(u.gender!)', '\(u.email)', \(u.registerNumber), \(u.address.objectId!))", "it isn't compatible")
        }
        
        /*
         Change Object
         to new age and automatic change to updatedAt
        */
        trace = []
        for (index, u) in userList.enumerated() {
            u.age = Int(arc4random_uniform(90))
            
            let cal = Calendar.current
            u.birthday = (cal as NSCalendar).date(byAdding: .day, value: -Int(arc4random_uniform(30)), to: Date(), options: [])
            u.birthday = (cal as NSCalendar).date(byAdding: .month, value: -Int(arc4random_uniform(12)), to: u.birthday!, options: [])
            u.birthday = (cal as NSCalendar).date(byAdding: .year, value: -u.age, to: u.birthday!, options: [])
            u.birthday = (cal as NSCalendar).date(byAdding: .hour, value: -Int(arc4random_uniform(60)), to: u.birthday!, options: [])
            u.birthday = (cal as NSCalendar).date(byAdding: .minute, value: -Int(arc4random_uniform(60)), to: u.birthday!, options: [])
            u.pin()
            
            XCTAssertTrue(trace[index] == "UPDATE User SET updatedAt = '\(u.updatedAt!.datatypeValue)', firstName = '\(u.firstName)', lastName = '\(u.lastName!)', age = \(u.age), birthday = '\(u.birthday!.datatypeValue)', gender = '\(u.gender!)', email = '\(u.email)', registerNumber = \(u.registerNumber), Address_objectId = \(u.address.objectId!) WHERE objectId = \(u.objectId!)", "it isn't compatible")
        }
        
        /*
         Delete Object
        */
        trace = []
        var i = 0
        for (index, u) in userList.enumerated() {
            if index % 3 == 0 {
                u.unPin()
            
                XCTAssertTrue(trace[i] == "DELETE FROM User WHERE objectId = \(u.objectId!)", "it isn't compatible")
                i += 1
            }
        }
        
        /*
         Transaction
        */
        trace = []
        let address = Address()
        let user = User()
        User.transaction {
            address.number = 101
            address.street = "Alpha Village"
            address.state  = "NY"
            address.zip    = 10203
            address.pin()
            
            user.firstName = "Bruno"
            user.lastName  = "Fernandes"
            user.age       = 29
            user.gender    = "male"
            let cal = Calendar.current
            user.birthday = (cal as NSCalendar).date(byAdding: .day, value: -Int(arc4random_uniform(30)), to: Date(), options: [])
            user.birthday = (cal as NSCalendar).date(byAdding: .month, value: -Int(arc4random_uniform(12)), to: user.birthday!, options: [])
            user.birthday = (cal as NSCalendar).date(byAdding: .year, value: -user.age, to: user.birthday!, options: [])
            user.email = "bruno@brunofernandes.me"
            user.registerNumber = 987654
            user.address = address
            user.pin()
        }
        
        XCTAssertTrue(trace[0] == "BEGIN DEFERRED TRANSACTION", "it isn't compatible")
        XCTAssertTrue(trace[1] == "INSERT INTO Address ( createdAt, updatedAt, street, number, state, zip ) VALUES ('\(address.createdAt!.datatypeValue)', '\(address.updatedAt!.datatypeValue)', '\(address.street)', \(address.number), '\(address.state)', \(address.zip))", "it isn't compatible")
        XCTAssertTrue(trace[2] == "INSERT INTO User ( createdAt, updatedAt, firstName, lastName, age, birthday, gender, email, registerNumber, Address_objectId ) VALUES ('\(user.createdAt!.datatypeValue)', '\(user.updatedAt!.datatypeValue)', '\(user.firstName)', '\(user.lastName!)', \(user.age), '\(user.birthday!.datatypeValue)', '\(user.gender!)', '\(user.email)', \(user.registerNumber), \(user.address.objectId!))", "it isn't compatible")
        XCTAssertTrue(trace[3] == "COMMIT TRANSACTION", "it isn't compatible")
        
        
        // Delete all Object
        trace = []
        User.clean()
        Address.clean()
        User.unRegister()
        Address.unRegister()
        
        XCTAssertTrue(trace[0] == "DELETE FROM User", "it isn't compatible")
        XCTAssertTrue(trace[1] == "DELETE FROM Address", "it isn't compatible")
        XCTAssertTrue(trace[2] == "DROP TABLE User"   , "it isn't compatible")
        XCTAssertTrue(trace[3] == "DROP TABLE Address", "it isn't compatible")
    }
    
    func testPopulateDataOptional() {
        
        TestField.register()
        TestFieldOptional.register()
        
        var testFieldList        :[TestField] = []
        var testFieldOptionalList:[TestFieldOptional] = []
        
        /*
         Save object
         to type supported
         */
        
        trace = []
        for i in 0 ... 20  {
            let test = TestField()
            test.generateValue(i)
            
            test.pin()
            testFieldList.append(test)
                        
            XCTAssertTrue(trace[i] == "INSERT INTO FieldTest ( createdAt, updatedAt, varstring, varint, varint8, varint16, varint32, varint64, varuint, varuint8, varuint16, varuint32, varuint64, varbool, varfloat, vardouble, varnsstring, vardate, varnumber, vardata, identifier ) VALUES ('\(test.createdAt!.datatypeValue)', '\(test.updatedAt!.datatypeValue)', '\(test.varstring)', \(test.varint), \(test.varint8), \(test.varint16), \(test.varint32), \(test.varint64), \(test.varuint), \(test.varuint8), \(test.varuint16), \(test.varuint32), \(test.varuint64), \(test.varbool.datatypeValue), \(test.varfloat), \(test.vardouble), '\(test.varnsstring)', '\(test.vardate.datatypeValue)', \(test.varnumber.doubleValue), \(test.vardata.datatypeValue), '\(test.identifier)')", "it isn't compatible")
        }
        
        //to type optional support
        trace = []
        for i in 0 ... 30  {
            let test = TestFieldOptional()
            test.generateValue(i)
            
            test.pin()
            testFieldOptionalList.append(test)
            
            XCTAssertTrue(trace[i] == "INSERT INTO TestFieldOptional ( createdAt, updatedAt, optionalString, optionalNSString, optionalNSInteger, optionalDate, optionalNumber, optionalData ) VALUES ('\(test.createdAt!.datatypeValue)', '\(test.updatedAt!.datatypeValue)', \(convertNil(test.optionalString)), \(convertNil(test.optionalNSString)), \(convertNil(test.optionalNSInteger)), \(convertNil(test.optionalDate)), \(convertNil(test.optionalNumber)), \(convertNil(test.optionalData)))")
        }
    
        /*
         Change Object
         to new age and automatic change to updatedAt
         */
        trace = []
        for (index, t) in testFieldOptionalList.enumerated() {
            
            t.optionalString = "Ok"
            t.optionalNSString = "NString OK"
            t.optionalNSInteger = 10
            t.optionalDate = Date()
            t.optionalNumber = nil
            t.optionalData = String("Test Data Optional Ok").data(using: String.Encoding.utf8)!
       
            t.pin()
            
            XCTAssertTrue(trace[index] == "UPDATE TestFieldOptional SET updatedAt = '\(t.updatedAt!.datatypeValue)', optionalString = \(convertNil(t.optionalString)), optionalNSString = \(convertNil(t.optionalNSString)), optionalNSInteger = \(convertNil(t.optionalNSInteger)), optionalDate = \(convertNil(t.optionalDate)), optionalNumber = \(convertNil(t.optionalNumber)), optionalData = \(convertNil(t.optionalData)) WHERE objectId = \(t.objectId!)", "it isn't compatible")
        }
        
        /*
         Transaction
         */
        trace = []
        let test:TestFieldOptional = testFieldOptionalList.last!
        TestFieldOptional.transaction {
            test.optionalString = nil
            test.optionalNSString = nil
            test.optionalNSInteger = nil
            test.optionalDate = nil
            test.optionalNumber = nil
            test.optionalData = nil

            test.pin()
        }
        
        XCTAssertTrue(trace[0] == "BEGIN DEFERRED TRANSACTION", "it isn't compatible")
        XCTAssertTrue(self.trace[1] == "UPDATE TestFieldOptional SET updatedAt = '\(test.updatedAt!.datatypeValue)', optionalString = \(convertNil(test.optionalString)), optionalNSString = \(convertNil(test.optionalNSString)), optionalNSInteger = \(convertNil(test.optionalNSInteger)), optionalDate = \(convertNil(test.optionalDate)), optionalNumber = \(convertNil(test.optionalNumber)), optionalData = \(convertNil(test.optionalData)) WHERE objectId = \(test.objectId!)", "it isn't compatible")
        XCTAssertTrue(trace[2] == "COMMIT TRANSACTION", "it isn't compatible")
        
        /*
         Delete Object
         */
        trace = []
        var i = 0
        for (index, t) in testFieldOptionalList.enumerated() {
            if index % 3 == 0 {
                t.unPin()
                
                XCTAssertTrue(trace[i] == "DELETE FROM TestFieldOptional WHERE objectId = \(t.objectId!)", "it isn't compatible")
                i += 1
            }
        }
        
        // Delete all Object
        trace = []
        TestField.clean()
        TestFieldOptional.clean()
        TestField.unRegister()
        TestFieldOptional.unRegister()
        
        XCTAssertTrue(trace[0] == "DELETE FROM FieldTest", "it isn't compatible")
        XCTAssertTrue(trace[1] == "DELETE FROM TestFieldOptional", "it isn't compatible")
        XCTAssertTrue(trace[2] == "DROP TABLE FieldTest"   , "it isn't compatible")
        XCTAssertTrue(trace[3] == "DROP TABLE TestFieldOptional", "it isn't compatible")
    }
    
    func testPerformanceExample() {
        // Media : 3.410
        self.measure {
            TestField.register()
            for _ in 0..<1000 {
                let t = TestField()
                t.pin()
            }
            TestField.clean()
            TestField.unRegister()
        }
    }
    
}
