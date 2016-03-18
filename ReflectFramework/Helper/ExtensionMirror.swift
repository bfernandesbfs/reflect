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
        return "Teste"
    }
    
}

