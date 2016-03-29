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
    
    func testRegister() {
        XCTAssert(TesteObjects.register(), "found error when if register the object")
    }
    
    func testPin() {
        var testeObjects = TesteObjects()
        XCTAssert(testeObjects.pin(), "Not was created a new object for TesteObjects")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
