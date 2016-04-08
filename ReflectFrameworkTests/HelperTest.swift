//
//  HelperTest.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 08/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

func convertNil<T>(obj:T?) -> String {
    if obj == nil {
        return "NULL"
    }
    else if let value = obj as? String {
        return "'\(value)'"
    }
    else if let value = obj as? NSDate {
        return "'\(value.datatypeValue)'"
    }
    else if let value = obj as? NSData {
        return "\(value.datatypeValue)"
    }
    else if let value = obj as? Double {
        return String(value)
    }
    else if let value = obj as? NSInteger {
        return String(value)
    }
    else {
        return String(obj!)
    }}