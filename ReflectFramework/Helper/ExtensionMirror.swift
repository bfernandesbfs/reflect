//
//  ExtensionMirror.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

extension Mirror {
    
    static func refectObject(kls:AnyObject) -> [MirrorModel] {
        let aMirror = self.init(reflecting: kls)
        var properties = [MirrorModel]()
        for case let (label?, anyValue) in aMirror.children {
            if let type = reflectType(Mirror(reflecting: anyValue).subjectType) {
                if let value = anyValue as? AnyObject {
                    properties.append(MirrorModel(key: label, value: value, type: type))
                }
                else{
                    var value: Any?
                    let mirrored = Mirror(reflecting:anyValue)
                    if mirrored.displayStyle != .Optional {
                        value = anyValue
                    } else if let firstChild = mirrored.children.first {
                        value = firstChild.value
                    }
                    properties.append(MirrorModel(key: label, value: value as? AnyObject, type: type))
                }
            }
            else{
                assertionFailure("This property '\(label)' not is supported for Reflect")
            }
        }
        
        return properties
    }
    
    private static func reflectType(type:Any) -> String! {
        switch type {
        case is String.Type, is Optional<String>.Type, is NSString.Type, is Optional<NSString>.Type:
            return String.declaredDatatype
        case is Int.Type, is Optional<Int>.Type,is Int64.Type, is Optional<Int64>.Type,is NSInteger.Type:
            return Int.declaredDatatype
        case is Double.Type, is Optional<Double>.Type:
            return Double.declaredDatatype
        case is Float.Type, is Optional<Float>.Type,is Float64.Type, is Optional<Float64>.Type:
            return Float.declaredDatatype
        case is NSNumber.Type, is Optional<NSNumber>.Type:
            return NSNumber.declaredDatatype
        case is Bool.Type, is Optional<Bool>.Type:
            return Bool.declaredDatatype
        case is NSDate.Type, is Optional<NSDate>.Type:
            return NSDate.declaredDatatype
        case is NSData.Type, is Optional<NSData>.Type:
            return NSData.declaredDatatype
        default:
            return nil
        }
    }
    
}

