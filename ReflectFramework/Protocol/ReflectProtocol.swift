//
//  ReflectProtocol.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 28/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation
/**
 *  Reflect Protocol
 */
public protocol ReflectProtocol {
    /// ObjectId gera automaticamente um numero inteiro que corresponde ao auto incremmet
    var objectId:NSNumber? { get set }
    /// CreatedAt contém a informação do momento que o registro foi criado
    var createdAt:Date?  { get set }
    /// UpdatedAt contém a informação do momento que o registro foi alterado
    var updatedAt:Date?  { get set }
    /**
     Inicialido default
     
     - returns: return value class
     */
    init()
    /**
     Entity Name - Contem o nome da table a ser criada, se não informada o ReflectFramework extrai os dados da class
                 - Se sobrescrever o metodo será utilizado para criar o entidade no banco de dados
     
     - returns: return Name of entity
     */
    static func entityName() -> String
}

/**
 *  Fields Protocol
 *  Implement this protocol to ignore arbitrary properties
 */
public protocol FieldsProtocol {
    /**
     Method used to define a set of ignored properties
     
     - returns: set of property names
     */
    static func ignoredProperties() -> Set<String>
}
// MARK: - Extension ReflectProtocol Method Statics
public extension ReflectProtocol {
    /**
     Query Object - Criar um instancia que possibilita realizar filtros dos dados 
     
     - returns: return uma nova instancia de Query
     */
    static func query() -> Query<Self> {
        return Query()
    }
    /**
     Este metodos create uma tabela com as propriedade do objetos
     
     - returns: return if the object was created with successfully
     */
    @discardableResult
    static func register() -> Bool {
        return Reflect.execute {
            return try Driver().create(self)
            }.success
    }
    /**
     Este metodo destroy o object na base de dados
     
     - returns: return if the object was created with successfully
     */
    @discardableResult
    static func unRegister() -> Bool {
        return Reflect.execute {
            return try Driver().drop(self)
            }.success
    }
    /**
     Procura os objects relacionado com os criterios dos filters
     
     - parameter query: Query object
     
     - returns: return os objects de acordo com o filtro
     */
    static func findObject(_ query:Query<Self>) -> [Self] {
        return Reflect.execute {
            return try Driver().find(query)
            }.data!
    }
    /**
     Get the object with objectId especifico 
     Optional include se o object conter sub class de ReflectFramework, é obrigatorio informar a class para trazer o objecto completo
     
     - parameter id:      objectId
     - parameter include: Class em conformidade with protocol ReflectFramework
     
     - returns: return the object or return nil if object not found
     */
    static func findById(_ id: Int, include:Any.Type...) -> Self? {
        guard let data = (Reflect.execute { return try Driver().find(id, include: include)! }.data) as Self? else {
            return nil
        }
        return data
    }
    /**
     Clean all objects created on Data Base
     
     - returns: return if the object was created with successfully
     */
    @discardableResult
    static func clean() -> Bool {
        return Reflect.execute {
            return try Driver().removeAll(self)
            }.success
    }
    /**
     Create a SQLite index on the specified table and column
     
     - parameter field:  Column names that the index will be applied
     - parameter unique: True if the index should be unique, false if it should not be unique (defaults to false)
     
     - returns: return if the object was created with successfully
     */
    @discardableResult
    static func index(_ field: String, unique:Bool = false) -> Bool {
        return Reflect.execute {
            return try Driver().index(self, field: field, unique: unique)
            }.success
    }
    /**
     Remove a SQLite index by its name
     
     - parameter field: The name of the index to be removed
     
     - returns: return if the object was created with successfully
     */
    @discardableResult
    static func removeIndex(_ field: String) -> Bool {
        return Reflect.execute {
            return try Driver().dropIndex(self, field: field)
            }.success
    }
    
    /**
     Transaction for query SQLite
    
     - parameter callback: callback instrutions
    
     */
    static func transaction(_ callback: @escaping () throws -> Void) {
        Reflect.execute {
            try Driver().transaction(self, callback: callback)
        }
    }
}
// MARK: - Extension ReflectProtocol Public methods
public extension ReflectProtocol {
    /**
    Get data for a specified objectId
     
     - parameter include: Optional include se o object conter sub class de ReflectFramework, é obrigatorio informar a class para trazer o objecto completo
     
     - returns: return if the object was created with successfully
     */
    @discardableResult
    public func fetch(include:Any.Type...) -> Bool {
        return Reflect.execute {
            try Driver().fetch(self, include: include)
        }.success
    }
    /**
     Add or change objects to the database
     
     - returns: return if the object was created with successfully
     */
    @discardableResult
    public func pin() -> Bool {
        return Reflect.execute {
            try Driver().save(self)
        }.success
    }
    /**
     Remove objects to the database
     
     - returns: return if the object was created with successfully
     */
    @discardableResult
    public func unPin() -> Bool {
        return Reflect.execute {
            try Driver().delete(self)
        }.success
    }
}
