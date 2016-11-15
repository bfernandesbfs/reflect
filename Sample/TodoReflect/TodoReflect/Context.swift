//
//  Context
//  TodoReflect
//
//  Created by Bruno Fernandes on 04/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

open class Context {
    
    static let defaultContext = Context() // Singleton
    
    var paybacks = [Payback]()
    
    func list() -> [Payback] {
        let query = Payback.query()
        paybacks = query.findObject()
        return paybacks
    }
    
    func addPayback(_ payback: Payback) {
        payback.pin()
        paybacks.insert(payback, at: 0)
    }
    
    func editPayback(_ index: Int, firstName: String, lastname: String, amount: Double, updated: Date) {
        let payback = paybacks[index]
        payback.firstName = firstName
        payback.lastName = lastname
        payback.amount = amount
        payback.pin()
    }
    
    func removePayback(_ index: Int) {
        let item = paybacks.remove(at: index)
        item.unPin()
    }
    
}
