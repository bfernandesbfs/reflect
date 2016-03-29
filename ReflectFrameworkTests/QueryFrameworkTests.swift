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
        
        t.filter("year", Comparison.LessThan, value: 2000)
        
        let list:[Car] = Car.findObject(t)
        
        print(list.count , list.first!.createAt)
    }
    
    func testQuery() {
    
        let q = Query<Car>()
        
        q.filter("year", .NotEquals, value: 2010)
        
        let list:[Car] = q.findObject()
        
        XCTAssertGreaterThan(list.count , 1, "Many Objects found")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
