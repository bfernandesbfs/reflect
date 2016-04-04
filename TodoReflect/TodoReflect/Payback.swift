//
//  Payback
//  TodoReflect
//
//  Created by Bruno Fernandes on 04/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import ReflectFramework

class Payback: Reflect {
    
    var firstName: String
    var lastName: String
    var amount: Double
    
    required init() {
        self.firstName = ""
        self.lastName = ""
        self.amount = 0.0

    }
    
    convenience init(firstName: String, lastName: String, amount: Double) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.amount = amount
    }
    
}

func ==(l: Payback, r: Payback) -> Bool {
    return l.objectId == r.objectId
}