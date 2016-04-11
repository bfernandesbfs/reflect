//
//  QueryFrameworkTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 11/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import XCTest
@testable import ReflectFramework

class QueryFrameworkTest: XCTestCase {

    var trace:[String] = []
    
    override func setUp() {
        super.setUp()
        
        Reflect.configuration("", baseNamed: "Tests.db")
        Reflect.settings.log { (SQL:String) in
            self.trace.append(SQL)
        }
        
        //populateData()
        populateDataFake()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testQueryObjectClass() {
        trace = []
        /**
         Find an Object
         */
        var usr1 = User.findById(1)
        XCTAssertTrue(trace[0] == "SELECT * FROM User WHERE User.objectId = 1;", "it isn't compatible")
        XCTAssertTrue(usr1!.address.objectId == nil , "it isn't compatible")
        
        // Include another object
        // type Reflect Object
        usr1 = User.findById(1, include: Address.self)
        XCTAssertTrue(trace[1] == "SELECT Address.objectId AS 'Address.objectId', Address.createdAt AS 'Address.createdAt', Address.updatedAt AS 'Address.updatedAt', Address.street AS 'Address.street', Address.number AS 'Address.number', Address.state AS 'Address.state', Address.zip AS 'Address.zip', User.* FROM User INNER JOIN Address ON User.Address_objectId = Address.objectId WHERE User.objectId = 1;", "it isn't compatible")
        XCTAssertTrue(usr1!.address.objectId != nil , "it isn't compatible")
        
        /**
         Fetch an Object
         */
        let usr2 = User()
        usr2.objectId = 2
        usr2.fetch()
        XCTAssertTrue(trace[2] == "SELECT * FROM User WHERE User.objectId = 2;", "it isn't compatible")
        XCTAssertTrue(usr2.address.objectId == nil , "it isn't compatible")
        
        // Include another object
        // type Reflect Object
        usr2.fetch(include: Address.self)
        XCTAssertTrue(trace[3] == "SELECT Address.objectId AS 'Address.objectId', Address.createdAt AS 'Address.createdAt', Address.updatedAt AS 'Address.updatedAt', Address.street AS 'Address.street', Address.number AS 'Address.number', Address.state AS 'Address.state', Address.zip AS 'Address.zip', User.* FROM User INNER JOIN Address ON User.Address_objectId = Address.objectId WHERE User.objectId = 2;", "it isn't compatible")
        XCTAssertTrue(usr2.address.objectId != nil , "it isn't compatible")
    
    }

    func testQueryAggregate() {
        
        trace = []
        /**
         Count Object
         */
        let query = User.query()
        let count = query.count()
        XCTAssertTrue(trace[0] == "SELECT COUNT(*) AS count FROM User", "it isn't compatible")
        XCTAssertTrue(count == Double(userList.count), "it isn't compatible")
        
        /**
         Sum Object
         */
        let sum = query.sum("age")
        XCTAssertTrue(trace[1] == "SELECT SUM(age) AS value FROM User", "it isn't compatible")
        
        let agesTotal:Int = userList.map {
            return $0.age
            }.reduce(0) {
                return $0 + $1
        }
        
        XCTAssertTrue(sum == Double(agesTotal), "it isn't compatible")
        
        /**
         Avg Object
         */
        let avg = query.average("age")
        XCTAssertTrue(trace[2] == "SELECT AVG(age) AS average FROM User", "it isn't compatible")
        XCTAssertTrue(avg == (Double(agesTotal) / count ), "it isn't compatible")
        
        /**
         Max Object
         */
        let max = query.max("birthday") as! String
        XCTAssertTrue(trace[3] == "SELECT MAX(birthday) AS maximum FROM User", "it isn't compatible")
        
        let listDate = userList.map ({ $0.birthday! })
        let maxDate = listDate.reduce(listDate[0]){$0 > $1 ? $1 : $0}.datatypeValue
        
        XCTAssertTrue(maxDate == max, "it isn't compatible")
        

        /**
         Min Object
         */
        let min = query.min("birthday") as! String
        XCTAssertTrue(trace[4] == "SELECT MIN(birthday) AS minimum FROM User", "it isn't compatible")
        
        let minDate = listDate.reduce(listDate[0]){$0 < $1 ? $1 : $0}.datatypeValue
        
        XCTAssertTrue(minDate == min, "it isn't compatible")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
