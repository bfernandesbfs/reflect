//
//  ReflectData.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 28/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

internal struct ReflectData {
    
    internal let isOptional: Bool
    internal var type:       Any.Type?  = nil
    internal var name:       String?
    internal var value:      Value? = nil
    
    internal var isValid: Bool {
        return type != nil && name != nil
    }
    
    internal init(property: Mirror.Child) {
        self.name = property.label
        
        let mirror = Mirror(reflecting: property.value)
        isOptional = mirror.displayStyle == .Optional
        value = unwrap(property.value) as? Value
        
        type = typeForMirror(mirror)
    }
    
    internal func typeForMirror(mirror: Mirror) -> Any.Type? {
        if !isOptional {
            return mirror.subjectType
        }
        
        switch mirror.subjectType {
        case is Optional<String>.Type:      return String.self
        case is Optional<NSString>.Type:    return NSString.self

        case is Optional<NSDate>.Type:      return NSDate.self
        case is Optional<NSNumber>.Type:    return NSNumber.self
        case is Optional<NSData>.Type:      return NSData.self
            
        case is Optional<Bool>.Type:        return Bool.self
            
        case is Optional<Int>.Type:         return Int.self
        case is Optional<Int8>.Type:        return Int8.self
        case is Optional<Int16>.Type:       return Int16.self
        case is Optional<Int32>.Type:       return Int32.self
        case is Optional<Int64>.Type:       return Int64.self
        case is Optional<UInt>.Type:        return UInt.self
        case is Optional<UInt8>.Type:       return UInt8.self
        case is Optional<UInt16>.Type:      return UInt16.self
        case is Optional<UInt32>.Type:      return UInt32.self
        case is Optional<UInt64>.Type:      return UInt64.self
            
        case is Optional<Float>.Type:       return Float.self
        case is Optional<Double>.Type:      return Double.self
        default:                            return nil
        }
    }
    
    internal func unwrap(value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        
        /* Raw value */
        if mirror.displayStyle != .Optional {
            return value
        }
        
        /* The encapsulated optional value if not nil, otherwise nil */
        return mirror.children.first?.value
    }
}

extension ReflectData {
    internal static func validPropertyDataForObject (object: ReflectProtocol) -> [ReflectData] {
        return validPropertyDataForMirror(Mirror(reflecting: object))
    }
    
    internal static func validPropertyDataForObject (object: ReflectProtocol, ignoredProperties: Set<String>) -> [ReflectData] {
        return validPropertyDataForMirror(Mirror(reflecting: object), ignoredProperties: ignoredProperties)
    }
    
    internal static func validPropertyTypeForSchema (type: Any.Type) -> String {
        return typeForSchema(type)
    }
    
    private static func validPropertyDataForMirror(mirror: Mirror, ignoredProperties: Set<String> = []) -> [ReflectData] {
        var ignore = ignoredProperties
        if mirror.subjectType is FieldsProtocol.Type {
            ignore = ignore.union((mirror.subjectType as! FieldsProtocol.Type).ignoredProperties())
        }
        
        var propertyData: [ReflectData] = []
        
        /* Allow inheritance from storable superclasses using reccursion */
        if let superclassMirror = mirror.superclassMirror() where superclassMirror.subjectType is ReflectProtocol.Type {
            propertyData += validPropertyDataForMirror(superclassMirror, ignoredProperties: ignore)
        }
        
        /* Map children to property data and filter out ignored or invalid properties */
        propertyData += mirror.children.map {
            ReflectData(property: $0)
            }.filter({
                $0.isValid && !ignore.contains($0.name!)
            })
        return propertyData
    }
    
    private static func typeForSchema (type: Any.Type) -> String {
        switch type {
        case is String.Type, is NSString.Type, is Character.Type:
            return String.declaredDatatype
        case is Int.Type, is Int8.Type, is Int16.Type, is Int32.Type, is Int64.Type, is UInt.Type, is UInt8.Type, is UInt16.Type, is UInt32.Type, is UInt64.Type:
            return Int.declaredDatatype
        case is Double.Type:
            return Double.declaredDatatype
        case is Float.Type:
            return Float.declaredDatatype
        case is Bool.Type:
            return Bool.declaredDatatype
        case is NSNumber.Type:
            return NSNumber.declaredDatatype
        case is NSDate.Type:
            return NSDate.declaredDatatype
        case is NSData.Type:
            return NSData.declaredDatatype
        default:
            fatalError("Error object not supported")
        }
    }
    
}