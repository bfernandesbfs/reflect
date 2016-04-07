//
//  CreateFrameworkTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 07/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import XCTest
@testable import ReflectFramework

class CreateFrameworkTest: XCTestCase {
    
    var trace:[String] = []
    
    override func setUp() {
        super.setUp()
        
        Reflect.configuration("", baseNamed: "Tests.db")
        Reflect.settings.log { (SQL:String) in
            self.trace.append(SQL)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testObjectSettings() {
        
        Reflect.configuration(.Temporary, readonly: true)
        
        let connTemporary = Reflect.settings.getConnection()
        XCTAssertTrue(connTemporary.readonly)
        XCTAssertEqual("", connTemporary.description)
        
        Reflect.configuration(.InMemory, readonly: true)
        
        let connInMemory = Reflect.settings.getConnection()
        XCTAssertTrue(connInMemory.readonly)
        XCTAssertEqual("", connInMemory.description)
        
        let path = "\(NSTemporaryDirectory())Tests.db"
        Reflect.configuration(.URI(path), readonly: false)
        
        let connURI = Reflect.settings.getConnection()
        XCTAssertFalse(connURI.readonly)
        XCTAssertEqual(path, connURI.description)
        
        Reflect.configuration("", baseNamed: "Tests.db")
        
        let connDefault = Reflect.settings.getConnection()
        XCTAssertFalse(connDefault.readonly)
        XCTAssertNotEqual("", connDefault.description)
    }
    
    func testObject() {
        /**
         Create Object
         */
        User.register()
        Address.register()
        TestField.register()
        
        XCTAssertTrue(trace[0] == "CREATE TABLE IF NOT EXISTS User (objectId INTEGER PRIMARY KEY AUTOINCREMENT, createdAt DATE, updatedAt DATE, firstName TEXT NOT NULL, lastName TEXT, age INTEGER NOT NULL, birthday DATE, gender TEXT, email TEXT NOT NULL, registerNumber INTEGER NOT NULL, Address_objectId INTEGER NOT NULL)", "it isn't compatible")
        XCTAssertTrue(trace[1] == "CREATE TABLE IF NOT EXISTS Address (objectId INTEGER PRIMARY KEY AUTOINCREMENT, createdAt DATE, updatedAt DATE, street TEXT NOT NULL, number INTEGER NOT NULL, state TEXT NOT NULL, zip INTEGER NOT NULL)")
        XCTAssertTrue(trace[2] == "CREATE TABLE IF NOT EXISTS FieldTest (objectId INTEGER PRIMARY KEY AUTOINCREMENT, createdAt DATE, updatedAt DATE, varstring TEXT NOT NULL, varint INTEGER NOT NULL, varint8 INTEGER NOT NULL, varint16 INTEGER NOT NULL, varint32 INTEGER NOT NULL, varint64 INTEGER NOT NULL, varuint INTEGER NOT NULL, varuint8 INTEGER NOT NULL, varuint16 INTEGER NOT NULL, varuint32 INTEGER NOT NULL, varuint64 INTEGER NOT NULL, varbool BOOLEAN NOT NULL, varfloat FLOAT NOT NULL, vardouble DOUBLE NOT NULL, varnsstring TEXT NOT NULL, vardate DATE NOT NULL, varnumber NUMERIC NOT NULL, vardata BLOB NOT NULL, identifier TEXT NOT NULL)")
        /**
         Create Index
         
         - parameter unique: if field unique key
         */
        User.index("registerNumber", unique: true)
        User.index("firstName")
        TestField.index("identifier", unique: true)
        
        XCTAssertTrue(trace[3] == "CREATE UNIQUE INDEX IF NOT EXISTS index_User_on_registerNumber ON User (registerNumber)"   , "it isn't compatible")
        XCTAssertTrue(trace[4] == "CREATE INDEX IF NOT EXISTS index_User_on_firstName ON User (firstName)", "it isn't compatible")
        XCTAssertTrue(trace[5] == "CREATE UNIQUE INDEX IF NOT EXISTS index_FieldTest_on_identifier ON FieldTest (identifier)"   , "it isn't compatible")
        /**
         Destroy Object
         */
        User.unRegister()
        Address.unRegister()
        TestField.unRegister()
        
        XCTAssertTrue(trace[6] == "DROP TABLE User"   , "it isn't compatible")
        XCTAssertTrue(trace[7] == "DROP TABLE Address", "it isn't compatible")
        XCTAssertTrue(trace[8] == "DROP TABLE FieldTest", "it isn't compatible")
    }
    
    func testObjectOptional() {
        /**
         Optional Create Object
         Type optional Supported:
         String
         NSString
         NSInteger
         NSNumber
         NSDate
         NSData
         */
        
        TestFieldOptional.register()
        
        XCTAssertTrue(trace[0] == "CREATE TABLE IF NOT EXISTS TestFieldOptional (objectId INTEGER PRIMARY KEY AUTOINCREMENT, createdAt DATE, updatedAt DATE, optionalString TEXT, optionalNSString TEXT, optionalNSInteger INTEGER, optionalDate DATE, optionalNumber NUMERIC, optionalData BLOB)")
        /**
         Create Index
         
         - parameter unique: if field unique key
         */
        TestFieldOptional.index("optionalNSInteger", unique: false)
        
        XCTAssertTrue(trace[1] == "CREATE INDEX IF NOT EXISTS index_TestFieldOptional_on_optionalNSInteger ON TestFieldOptional (optionalNSInteger)", "it isn't compatible")
        /**
         Destroy Object
         */
        TestFieldOptional.unRegister()
        
        XCTAssertTrue(trace[2] == "DROP TABLE TestFieldOptional" , "it isn't compatible")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
