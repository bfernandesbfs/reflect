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
    
    var optionalString  : String?
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
        number = 111
        data   = String("Test Data").dataUsingEncoding(NSUTF8StringEncoding)!
    }
}
