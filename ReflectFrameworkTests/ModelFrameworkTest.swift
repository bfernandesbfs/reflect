//
//  ModelFrameworkTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 31/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import XCTest
@testable import ReflectFramework

class ModelFrameworkTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegisterClass() {
        XCTAssertTrue(Address.register(), "This object wasn't created")
        XCTAssertTrue(User.register(), "This object wasn't created")
    }
    
    func testDestroyClass() {
        XCTAssertTrue(Address.unRegister(), "This object wasn't deleted")
        XCTAssertTrue(User.unRegister(), "This object wasn't deleted")
    }
    
    func testRemoveAll() {
        XCTAssertTrue(User.clean(),"Not was delete all object")
    }
    
    func testIndex() {
        User.removeIndex("email")
        User.removeIndex("firstName")
    }
    
    func testPopulate() {
        var result = 0
        for (index, var a) in Address.populate().enumerate() {
            a.pin()
            result = index
        }
        XCTAssertTrue(result != 20 , "results is not in accordance with the objects that were saved in data base")
        
        func populateUser() -> Int {
            var result = 0
            for (index, var u) in User.populate().enumerate() {
                u.pin()
                result = index
            }
            return result
        }

        XCTAssertTrue(populateUser() != 20 , "results is not in accordance with the objects that were saved in data base")
        
    }
    
    func testPopulateUser() {
        
        var result = 0
        for (index, var u) in User.populate().enumerate() {
            u.address = Address.findById(index + 1)!
            u.pin()
            result = index
        }
        
        XCTAssertTrue(result != 20 , "results is not in accordance with the objects that were saved in data base")
        
    }
    
    func testPopulateChange() {
        var result = 0
        for (index, var u) in User.query().findObject().enumerate() {
            u.address = Address.findById(Int(arc4random_uniform(19)) + 1)!
            u.pin()
            result = index
        }
        XCTAssertTrue(result != 20 , "results is not in accordance with the objects that were changed in data base")
    }
        
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
