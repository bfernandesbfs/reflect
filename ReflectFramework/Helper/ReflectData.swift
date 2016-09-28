//
//  ReflectData.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 28/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

/**
 *  ReflectData
 */
internal struct ReflectData {
    /// Optinal object
    internal let isOptional: Bool
    /// Object type Class
    internal var isClass: Bool = false
    /// Type of object
    internal var type: Any.Type?  = nil
    /// Name of property
    internal var name: String?
    /// Value of property
    internal var value: Any? = nil
    /// Valid data on object
    internal var isValid: Bool {
        return type != nil && name != nil
    }
    /**
     Initialize
     
     - parameter property: Mirror Child
    
     */
    internal init(property: Mirror.Child) {
        self.name = property.label
        
        let mirror = Mirror(reflecting: property.value)
        isOptional = mirror.displayStyle == .optional
        value = unwrap(property.value)
        type = typeForMirror(mirror)
    }
    /**
     Type to property
     
     - parameter mirror: Mirror
     
     - returns: return Any.Type if nothing nil
     */
    internal mutating func typeForMirror(_ mirror: Mirror) -> Any.Type? {
        if !isOptional {
            if mirror.subjectType is Reflect.Type {
                isClass =  true
            }
            return mirror.subjectType
        }
    
        switch mirror.subjectType {
        case is Optional<String>.Type:    return String.self
        case is Optional<NSString>.Type:  return NSString.self
        case is Optional<Date>.Type:      return Date.self
        case is Optional<NSNumber>.Type:  return NSNumber.self
        case is Optional<Data>.Type:      return Data.self
        case is Optional<Bool>.Type:      return Bool.self
        case is Optional<Int>.Type:       return Int.self
        case is Optional<Int8>.Type:      return Int8.self
        case is Optional<Int16>.Type:     return Int16.self
        case is Optional<Int32>.Type:     return Int32.self
        case is Optional<Int64>.Type:     return Int64.self
        case is Optional<UInt>.Type:      return UInt.self
        case is Optional<UInt8>.Type:     return UInt8.self
        case is Optional<UInt16>.Type:    return UInt16.self
        case is Optional<UInt32>.Type:    return UInt32.self
        case is Optional<UInt64>.Type:    return UInt64.self
        case is Optional<Float>.Type:     return Float.self
        case is Optional<Double>.Type:    return Double.self
        case is Optional<Reflect.Type>.Type:
            isClass =  true
            return Reflect.self
        default:
            return nil
        }
    }
    /**
     Un wrap value
     
     - parameter value: property value
     
     - returns: return value
     */
    internal mutating func unwrap(_ value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        
        /* Raw value */
        if mirror.displayStyle != .optional {
            return value
        }
        
        /* The encapsulated optional value if not nil, otherwise nil */
        return mirror.children.first?.value
    }
}
// MARK: - Extension ReflectData Methods Static
internal extension ReflectData {
    
    internal static func validPropertyDataForObject (_ object: ReflectProtocol) -> [ReflectData] {
        return validPropertyDataForMirror(Mirror(reflecting: object))
    }
    
    internal static func validPropertyDataForObject (_ object: ReflectProtocol, ignoredProperties: Set<String>) -> [ReflectData] {
        return validPropertyDataForMirror(Mirror(reflecting: object), ignoredProperties: ignoredProperties)
    }
    
    internal static func validPropertyTypeForSchema (_ type: Any.Type) -> String {
        return typeForSchema(type)
    }
    
    fileprivate static func validPropertyDataForMirror(_ mirror: Mirror, ignoredProperties: Set<String> = []) -> [ReflectData] {
        var ignore = ignoredProperties
        if mirror.subjectType is FieldsProtocol.Type {
            ignore = ignore.union((mirror.subjectType as! FieldsProtocol.Type).ignoredProperties())
        }
        
        var propertyData: [ReflectData] = []
        
        /* Allow inheritance from storable superclasses using reccursion */
        if let superclassMirror = mirror.superclassMirror , superclassMirror.subjectType is ReflectProtocol.Type {
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
    
    fileprivate static func typeForSchema (_ type: Any.Type) -> String {
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
        case is Date.Type:
            return Date.declaredDatatype
        case is Data.Type:
            return Data.declaredDatatype
        case is Reflect.Type:
            return Int.declaredDatatype
        default:
            fatalError("Error object not supported")
        }
    }
}
