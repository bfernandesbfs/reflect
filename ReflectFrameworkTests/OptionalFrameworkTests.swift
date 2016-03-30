//
//  OptionalFrameworkTests.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 29/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import XCTest
@testable import ReflectFramework

class OptionalFrameworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegisterOptional() {
         XCTAssert(TesteObjectsOptional.register(), "found error when if register the object")
    }
    
    func testUnRegisterOptional() {
        XCTAssert(TesteObjectsOptional.unRegister(), "found error when if unregister the object")
    }
    
    func testRegister() {
        XCTAssert(TesteObjects.register(), "found error when if register the object")
    }
    
    func testUnRegister() {
        XCTAssert(TesteObjects.unRegister(), "found error when if unregister the object")
    }

    
    func testPin() {
        var testeObjects = TesteObjects()
        XCTAssert(testeObjects.pin(), "Not was created a new object for TesteObjects")
    }
    
    func testChange() {
        var testeObjects = TesteObjects()
        
        testeObjects.objectId = 5
        testeObjects.string    = "New String"
        testeObjects.int    = 10
        testeObjects.int8   = 20
        testeObjects.int16  = 30
        testeObjects.int32  = 40
        testeObjects.int64  = 50
        testeObjects.uint   = 60
        testeObjects.uint8  = 70
        testeObjects.uint16 = 80
        testeObjects.uint32 = 90
        testeObjects.uint64 = 100
        testeObjects.bool   = true
        testeObjects.float  = 10.10
        testeObjects.double = 10.20
        //Objc
        testeObjects.nsstring  = "New NSString"
        testeObjects.date   = NSDate()
        testeObjects.number = 120.6
        testeObjects.data   = String("Test new data").dataUsingEncoding(NSUTF8StringEncoding)!
        
        XCTAssert(testeObjects.pin(), "Not was created a new object for TesteObjects")
    }

    func testUnPin() {
        let testeObjects = TesteObjects()
        testeObjects.objectId = 1
        XCTAssert(testeObjects.unPin(), "Object TesteObjects was deleted")
    }
    
    func testFind(){
        let testeObjects = TesteObjects.findById(5)
        XCTAssert(testeObjects?.string == "New String", "Fetch Object is different")
    }
    
    
    func testPinOptional() {
        var testeObjectsOptional = TesteObjectsOptional()
        
        testeObjectsOptional.optionalString = nil
        //Objc
        testeObjectsOptional.optionalNSString  = "nsstring çã óê"
        testeObjectsOptional.optionalDate   = NSDate()
        testeObjectsOptional.optionalNumber = 12
        testeObjectsOptional.optionalData   = String("Test Data").dataUsingEncoding(NSUTF8StringEncoding)!
        
        XCTAssert(testeObjectsOptional.pin(), "Not was created a new object for TesteObjectsOptional")
    }
    
    func testChangeOptional() {
        var testeObjectsOptional = TesteObjectsOptional()
        
        testeObjectsOptional.objectId = 4
        testeObjectsOptional.optionalString = "New String"
        //Objc
        testeObjectsOptional.optionalNSString  = "New NSString"
        testeObjectsOptional.optionalDate   = NSDate()
        testeObjectsOptional.optionalNumber = 90.7
        testeObjectsOptional.optionalData   = String("Test new data").dataUsingEncoding(NSUTF8StringEncoding)!
        
        XCTAssert(testeObjectsOptional.pin(), "Not was created a new object for TesteObjectsOptional")
    }
    
    func testUnPinOptional() {
        let testeObjectsOptional = TesteObjectsOptional()
        testeObjectsOptional.objectId = 1
        XCTAssert(testeObjectsOptional.unPin(), "Object TesteObjectsOptional was deleted")
    }
    
    func testFindOptional(){
        let testeObjectsOptional = TesteObjectsOptional.findById(2)
        XCTAssert(testeObjectsOptional?.optionalString == "New String", "Fetch Object is different")
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
