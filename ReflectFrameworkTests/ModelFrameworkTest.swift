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
         XCTAssertTrue(User.register(), "This object wasn't created")
    }
    
    func testDestroyClass() {
        XCTAssertTrue(User.unRegister(), "This object wasn't deleted")
    }
    
    func testPopulate() {
    
        User.register()
        
        var result = 0
        for (index, var u) in User.populate().enumerate() {
            u.pin()
            result = index
        }
        XCTAssertTrue(result != 20 , "results is not in accordance with the objects that were saved in data base")
    }
    
    func testPopulateChange() {
        var result = 0
        for (index, var u) in User.query().findObject().enumerate() {
            let cal = NSCalendar.currentCalendar()
            let date = cal.dateByAddingUnit(.Minute, value: -Int(arc4random_uniform(60)), toDate: u.birthday!, options: [])
            u.birthday = date
            u.pin()
            result = index
        }
        XCTAssertTrue(result != 20 , "results is not in accordance with the objects that were changed in data base")
    }

    func testPopulateRemove() {
    
        for u in User.query().findObject() {
            u.unPin()
        }
        
        let result = User.query().count()
        
        XCTAssertFalse(result > 0 , "results is not in accordance with the objects that were deleted in data base")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
