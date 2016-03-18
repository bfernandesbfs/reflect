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
    
    func testRegister(){
        Car.register()
    }
    
    func testDestroy(){
        Car.unRegister()
    }
    
    func testTableName(){
         XCTAssert(Car.tableName() == "Car", "Object not was created with name informed")
    }
    
    func testFetch(){
        c.id = 2
        c.model = "Ferrari"
        c.fetch()
        
        XCTAssert(c.model == "Ferrari", "Fetch Object is different")
    }
    
    func testPin() {
        c.model = "Ferrari"
        c.year = 2016
        XCTAssert(c.pin(), "Not was created a new object for Car")
    }
    
    func testUnPin(){
        c.id = 2
        XCTAssert(c.unPin(), "Object car was deleted")
    }
    
    func testUnPinAll(){
        XCTAssert(Car.unPinAll(), "All Objects deleted")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
