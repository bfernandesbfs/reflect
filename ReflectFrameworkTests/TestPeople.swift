//
//  TestPeople.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//


@testable import ReflectFramework

class Car: Reflect  {
    var name:String?
    var model:String?
    var year:Int
    
    required init(){
        year = 0
    }
}


