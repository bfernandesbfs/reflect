//
//  ModelQueryFrameworkTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 01/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import XCTest
@testable import ReflectFramework

class ModelQueryFrameworkTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testQuery() {
        
        let user1 = User()
        user1.objectId = 35
        user1.fetch(include: Address.self)
        
        let user2 = User.findById(35, include: Address.self)!
        
        XCTAssertTrue(user1.firstName == user2.firstName , "Not match object when user querys")
        
        let query = User.query()
        var value = query.filter("age", Comparison.LessThan, value: 20) .count()
        
        XCTAssertTrue(value != 0 , "Error found")
        
        let query1 = Address.query()
        
        value = query1.filter("state", .Equals, value: "MI").count()
        
        XCTAssertTrue(value != 0 , "Error found")
    }
    
    func testRelationQuery() {
        
        let query = User.query()
        query.filter("User.objectId", Comparison.GreaterThan, value: 22).filter("firstName", .Like, value: "%da") .distinct()
        
        query.join(Address.self)
    
        for q in query.findObject(){
            print("\(q.objectId!)\t\t\(q.firstName)\t\t\t\(q.lastName!)\t\t\t\(q.age)")
            print("\(q.address.objectId!)\t\(q.address.state)")
        }
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
