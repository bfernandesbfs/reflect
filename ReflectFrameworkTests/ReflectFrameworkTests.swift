//
//  ReflectFrameworkTests.swift
//  ReflectFrameworkTests
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import XCTest
@testable import ReflectFramework

class ReflectFrameworkTests: XCTestCase {
    
    let c = Car()
    
    override func setUp() {
        super.setUp()
        testRegister()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultSettings(){
        XCTAssert(Reflect.settings.getDBName() == "ReflectDB.db", "Data base and path not created")
    }
    
    func testSettings(){
        Reflect.configuration("", baseNamed: "Teste")
        XCTAssert(Reflect.settings.getDBName() == "Teste.db", "Data base and path not created")
    }
    
    func testRegister(){
        XCTAssert(Car.register(), "found error when if register the object")
    }
    
    func testDestroy(){
        XCTAssert(Car.unRegister(), "found error when remove o object")
    }
    
    func testTableName(){
        XCTAssert(Car.tableName() == "Car", "Object not was created with name informed")
    }
    
    func testFind(){
        let n = Car.findById(1)
        
        XCTAssert(n?.name == "VW", "Fetch Object is different")
    }
    
    func testFetch(){
        let n = Car()
        n.id = 2
        print(n.fetch())
    
        XCTAssert(n.year == 2015, "Fetch Object is different")
    }
    
    func testPin() {
        c.name = "Renault"
        c.model = "Logan"
        c.year = 2010
        
        print(c.pin())
        
       // XCTAssert(c.pin(), "Not was created a new object for Car")
    }
    
    func testUpdate(){
        c.id = 4
        c.name = "GM"
        c.model = "Corsa"
        c.year = 2011
        
        print(c.pin())
        
        // XCTAssert(c.pin(), "Not was created a new object for Car")
        
    }
    
    func testUnPin(){
        c.id = 2
        XCTAssert(c.unPin(), "Object car was deleted")
    }
    
    func testUnPinAll(){
        XCTAssert(Car.unPinAll(), "All Objects deleted")
    }
    
    func testFlow(){
        Reflect.configuration("", baseNamed: "Teste")
        XCTAssert(Reflect.settings.getDBName() == "Teste.db", "Data base and path not created")
        
        XCTAssert(Car.register(), "found error when if register the object")
        let n = Car()
        n.model = "Polo"
        n.year  = 2008
        
        XCTAssert(n.pin(), "Not was created a new object for Car")
        print("Id object : \(n.id)")
        
        XCTAssert(n.unPin(), "Object car was deleted")
        
        Car.unPinAll()
        XCTAssert(Car.unRegister(), "found error when remove o object")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
