//
//  QueryFrameworkTests.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import XCTest
@testable import ReflectFramework

class QueryFrameworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testIncludeQuery() {
    
        let t = Car.query()
        
        t.filter("id", .Equals, value: 2).filter("firstName", .In, value: "Bruno", "Bruno2","Bruno3")
        
        t.list()
        
    }
    
    func testQuery() {
    
        let q = Query<Car>()
        
        q.filter("id", .NotEquals, value: "2")

        q.list()
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
