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
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testIncludeQuery() {
    
        let t = Car.query()
        
        t.filter("year", Comparison.GreaterThan, value: 2000)
        
        let list:[Car] = Car.findObject(t)
        
        print(list.count , list.first!.createdAt)
    }
    
    func testQuery() {
    
        let q = Query<Car>()
        
        q.filter("model", .NotEquals, value: "Fusca")
        
        let list:[Car] = q.findObject()
        
        XCTAssertGreaterThan(list.count , 1, "Many Objects found")
        
    }
    
    func testIncludeOptionalQuery() {
        
        let testeObjectsOptional = TesteObjectsOptional.query()
        
        testeObjectsOptional.filter("objectId", Comparison.GreaterThan, value: 2).sort("optionalString", .Desc).sort("objectId", .Asc).limit(2)
        
        let list:[TesteObjectsOptional] = TesteObjectsOptional.findObject(testeObjectsOptional)
        
        print(list.count , list.first!.createdAt)
    }
    
    func testOptionalQuery() {
        
        let query = Query<TesteObjectsOptional>()
        
        query.fields("optionalString").filter("objectId", Comparison.GreaterThan, value: 2).sort("optionalString", .Desc).sort("objectId", .Asc).limit(2)
        
        let list:[TesteObjectsOptional] = query.findObject()
        
        XCTAssertGreaterThan(list.count , 1, "Many Objects found")
        
    }
    
    func testOptionalQueryCount() {
        
        let query = Query<TesteObjectsOptional>()
        
        let value = query.fields("optionalString").filter("objectId", Comparison.GreaterThan, value: 2).sort("optionalString", .Desc).sort("objectId", .Asc).count()
        
        XCTAssertGreaterThan(value, 1, "Count Objects Not found")
    }
    
    func testOptionalQuerySum() {
        
        let query = Query<TesteObjectsOptional>()
        
        let value = query.filter("objectId", Comparison.GreaterThan, value: 2).sum("optionalNumber")
    
        XCTAssertGreaterThan(value, 1, "Sum of Objects not found")
    }
    
    func testOptionalQueryMax() {
        
        let query = Query<TesteObjectsOptional>()
        
        let value = query.filter("objectId", Comparison.GreaterThan, value: 2).max("optionalNumber")
        
        XCTAssertGreaterThan(value, 1, "Max of Objects not found")
    }
    
    func testOptionalQueryMin() {
        
        let query = Query<TesteObjectsOptional>()
        
        let value = query.filter("objectId", Comparison.GreaterThan, value: 2).min("optionalNumber")
        
        XCTAssertGreaterThan(value, 1, "Min of Objects not found")
    }
    
    func testOptionalQueryAvg() {
        
        let query = Query<TesteObjectsOptional>()
        
        let value = query.filter("objectId", Comparison.GreaterThan, value: 2).average("optionalNumber")
        
        XCTAssertGreaterThan(value, 1, "Min of Objects not found")
    }
    
    func testExcludeQuery() {
        let query = Reflect.query("SELECT COUNT(*) as count FROM TesteObjectsOptional WHERE optionalString IS NULL").first!
        print(query["count"] as? Int64)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
