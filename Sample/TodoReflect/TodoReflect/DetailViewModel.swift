//
//  DetailsViewModel
//  TodoReflect
//
//  Created by Bruno Fernandes on 04/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

open class DetailViewModel {

    open let context: Context = Context.defaultContext
    open var title = "New Payback"
    open var name = ""
    open var amount = ""
    open weak var delegate: DetailViewModelDelegate?
    
    open var infoText: String {
        _ = nameComponents
        let amount = (self.amount as NSString).doubleValue
        return "\(name)\n\(amount)"
    }
    
    fileprivate var index: Int = -1
    
    var isNew: Bool {
        return index == -1
    }
    
    // new initializer
    public init(delegate: DetailViewModelDelegate) {
        self.delegate = delegate
    }
    
    // edit initializer
    public convenience init(delegate: DetailViewModelDelegate, index: Int) {
        self.init(delegate: delegate)
        self.index = index
        print(index)
        title = "Edit Payback"
        let payback = context.paybacks[index]
        name = payback.firstName + " " + payback.lastName
        amount = "\(payback.amount)"
    }
    
    open func handleDonePressed() {
        if !validateName() {
            delegate?.showInvalidName()
        }
        else if !validateAmount() {
            delegate?.showInvalidAmount()
        }
        else {
            if isNew {
                addPayback()
            }
            else {
                savePayback()
            }
            delegate?.dismissAddView()
        }
    }
    
    fileprivate var nameComponents : [String] {
        return name.components(separatedBy: " ").filter { !$0.isEmpty }
    }
    
    
    func validateName() -> Bool {
        return nameComponents.count >= 2
    }
    
    func validateAmount() -> Bool {
        let value = (amount as NSString).doubleValue
        return value.isNormal && value > 0
    }
    
    func addPayback() {
        let names = nameComponents
        let amount = (self.amount as NSString).doubleValue
        let payback = Payback(firstName: names[0], lastName: names[1], amount: amount)
        context.addPayback(payback)
    }
    
    func savePayback() {
        let names = nameComponents
        let amount = (self.amount as NSString).doubleValue
        context.editPayback(index, firstName: names[0], lastname: names[1], amount: amount, updated: Date())
    }
    
}

public protocol DetailViewModelDelegate: class {
    func dismissAddView()
    func showInvalidName()
    func showInvalidAmount()
}
