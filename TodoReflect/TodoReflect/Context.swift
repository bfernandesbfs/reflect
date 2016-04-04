//
//  Context
//  TodoReflect
//
//  Created by Bruno Fernandes on 04/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

public class Context {
    
    static let defaultContext = Context() // Singleton
    
    var paybacks = [Payback]()
    
    func list() -> [Payback] {
        let query = Payback.query()
        paybacks = query.findObject()
        return paybacks
    }
    
    func addPayback(payback: Payback) {
        payback.pin()
        paybacks.insert(payback, atIndex: 0)
    }
    
    func editPayback(index: Int, firstName: String, lastname: String, amount: Double, updated: NSDate) {
        let payback = paybacks[index]
        payback.firstName = firstName
        payback.lastName = lastname
        payback.amount = amount
        payback.pin()
    }
    
    func removePayback(index: Int) {
        let item = paybacks.removeAtIndex(index)
        item.unPin()
    }
    
}
