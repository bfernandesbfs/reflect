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
    
    var c = Car()
    
    override func setUp() {
        super.setUp()
        //testRegister()
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
        XCTAssert(Car.entityName() == "Car", "Object not was created with name informed")
    }
    
    func testFind(){
        let n = Car.findById(1)
        
        XCTAssert(n?.name == "GM", "Fetch Object is different")
    }
    
    func testFetch(){
        let n = Car()
        n.objectId = 2
        n.fetch()
    
        XCTAssert(n.year == 1984, "Fetch Object is different")
    }
    
    func testChange() {
        c.objectId = 2
        c.name = "VW"
        c.model = "Fusca"
        c.year = 1984

        XCTAssert(c.pin(), "Not was created a new object for Car")
    }
    
    func testPin() {
        //c.objectId = 4
        c.name = "Renault"
        c.model = "Logan"
        c.year = 2010
    
        XCTAssert(c.pin(), "Not was created a new object for Car")
    }
    
    func testUpdate(){
        c.objectId = 5
        c.name = "VW"
        c.model = "Polo"
        c.year = 2008
        
        XCTAssert(c.pin(), "Not was created a new object for Car")
    }
    
    func testUnPin(){
        c.objectId = 5
        XCTAssert(c.unPin(), "Object car was deleted")
    }
    
    func testClear(){
        XCTAssert(Car.clean(), "All Objects deleted")
    }
    
    func testFlow(){
        Reflect.configuration("", baseNamed: "Teste")
        XCTAssert(Reflect.settings.getDBName() == "Teste.db", "Data base and path not created")
        
        XCTAssert(Car.register(), "found error when if register the object")
        var n = Car()
        n.model = "Polo"
        n.year  = 2008
        
        XCTAssert(n.pin(), "Not was created a new object for Car")
        print("Id object : \(n.objectId)")
        
        XCTAssert(n.unPin(), "Object car was deleted")
        
        Car.clean()
        XCTAssert(Car.unRegister(), "found error when remove o object")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
