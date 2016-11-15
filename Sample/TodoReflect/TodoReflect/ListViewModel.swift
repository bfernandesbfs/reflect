//
//  ListViewModel
//  TodoReflect
//
//  Created by Bruno Fernandes on 04/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

open class ListViewModel {
    
    open let context = Context.defaultContext
    open var items = [Item]()
    
    open func refresh() {
        items = context.list().map {
            self.itemForPayback($0)
        }
        print(items)
    }
    
    func itemForPayback(_ payback: Payback) -> Item {
        let singleLetter = payback.lastName.substring(to: payback.lastName.characters.index(after: payback.lastName.startIndex))
        
        let title = "\(payback.firstName) \(singleLetter)."
        let subtitle = DateFormatter.localizedString(from: payback.createdAt!, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.none)
        
        let rounded = NSNumber(value: round(payback.amount) as Double).int64Value
        let amount = "$\(rounded)"
        
        let item = Item(title: title, subtitle: subtitle, amount: amount)
        
        return item
    }
    
    func removePayback(_ index: Int) {
        context.removePayback(index)
    }
    
    public struct Item {
        public let title: String
        public let subtitle: String
        public let amount: String
    }
    
}
