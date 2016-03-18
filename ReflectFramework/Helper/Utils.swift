//
//  Utils.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)

public var dateFormatter: NSDateFormatter = {
    return NSDateFormatter.defaultFormart()
}()

extension String {
    
    func quote(mark: Character = "\"") -> String {
        let escaped = characters.reduce("") { string, character in
            string + (character == mark ? "\(mark)\(mark)" : "\(character)")
        }
        return "\(mark)\(escaped)\(mark)"
    }
}

extension NSDateFormatter {
    
    convenience init(format:String?){
        self.init()
        dateFormat = format == nil ? "yyyy-MM-dd HH:mm:ss" : format
        locale = NSLocale.currentLocale()
        timeZone = NSTimeZone.systemTimeZone()
    }
    
    class func defaultFormart() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = NSLocale.currentLocale()
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return formatter
    }
}




