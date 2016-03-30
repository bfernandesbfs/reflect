//
//  Test.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//


@testable import ReflectFramework

class Car: Reflect {
    var name:String?
    var model:String?
    var year:Int
    
//    override class func tableName() -> String {
//        return "Car_"
//    }
    
    required init(){
        year = 0
    }
}


class TesteObjectsOptional: Reflect {
    
    var optionalString   : String?
    var optionalCharacter: Character?
    var optionalInt     : Int?
    var optionalInt8    : Int8?
    var optionalInt16   : Int16?
    var optionalInt32   : Int32?
    var optionalInt64   : Int64?
    var optionalUint    : UInt?
    var optionalUint8   : UInt8?
    var optionalUint16  : UInt16?
    var optionalUint32  : UInt32?
    var optionalUint64  : UInt64?
    var optionalBool    : Bool?
    var optionalFloat   : Float?
    var optionalDouble  : Double?
    
    //Objc
    var optionalNSString : NSString?
    var optionalDate    : NSDate?
    var optionalNumber  : NSNumber?
    var optionalData    : NSData?
    
    required init(){
    }
}

class TesteObjects: Reflect {
    
    var string     : String
    var character  : Character
    var int     : Int
    var int8    : Int8
    var int16   : Int16
    var int32   : Int32
    var int64   : Int64
    var uint    : UInt
    var uint8   : UInt8
    var uint16  : UInt16
    var uint32  : UInt32
    var uint64  : UInt64
    var bool    : Bool
    var float   : Float
    var double  : Double
    //Objc
    var nsstring: NSString
    var date    : NSDate
    var number  : NSNumber
    var data    : NSData
    
    required init(){
        string    = "string"
        character = "c"
        int    = 1
        int8   = 2
        int16  = 3
        int32  = 4
        int64  = 5
        uint   = 6
        uint8  = 7
        uint16 = 8
        uint32 = 9
        uint64 = 10
        bool   = false
        float  = 1.1
        double = 1.2
        //Objc
        nsstring  = "nsstring"
        date   = NSDate()
        number = 1.3
        data   = String("Test Data").dataUsingEncoding(NSUTF8StringEncoding)!
    }
}
