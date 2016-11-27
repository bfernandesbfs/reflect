[![Swift](https://img.shields.io/badge/swift-3-orange.svg?style=flat)](https://developer.apple.com/swift/) 
# Reflect

Reflect is an ActiveRecord framework, elegant and simple that use the SQLite in Swift.

- [x] Easy configuration
- [x] Simple syntax
- [x] Pure Swift

## Configuration Database

Temporary

``` swift
import CoreReflect

Reflect.configuration(.temporary, readonly: true)
let connTemporary = Reflect.settings.getConnection()    
               
```
InMemory

``` swift
import CoreReflect

Reflect.configuration(.inMemory, readonly: true)
let connInMemory = Reflect.settings.getConnection()
```
In-memory databases are automatically deleted when the database connection is closed.

Path
``` swift
import CoreReflect
         
let path = "\(NSTemporaryDirectory())Tests.db"
Reflect.configuration(.uri(path), readonly: false)
let connURI = Reflect.settings.getConnection()
       
```
App Group 
``` swift
import CoreReflect
         
Reflect.configuration("", baseNamed: "Tests.db")
let connDefault = Reflect.settings.getConnection()         
```

## Create Object

#### Inheritance
Add as inheritance class `Reflect` to your object.
``` swift
import CoreReflect

class User: Reflect {
    var firstName:String
    var lastName :String?
    var age:Int
    var birthday:Date?
    var gender:String?
    var email:String
    var registerNumber:Int
    
    var address: Address
    
    required init() {
        firstName = ""
        age       = 0
        email     = ""
        registerNumber = 0
        address = Address()
    }
}
```

#### Entity Name
We can change table name, implementation and method static `entityName`.
```
override class func entityName() -> String {
    return "My_Table_Name"
}
```

#### Ignored Properties
To ignore properties, we can implementation the method static `ignoredProperties`.
```
override class func ignoredProperties() -> Set<String> {
    return ["status", "register", "value"]
}
```

#### Register Object
Use `register` to create table.
``` swift
Address.register()
User.register()

// CREATE TABLE IF NOT EXISTS Address (objectId INTEGER PRIMARY KEY AUTOINCREMENT, createdAt DATE, updatedAt DATE, street TEXT NOT NULL, number INTEGER NOT NULL, state TEXT NOT NULL, zip INTEGER NOT NULL)
//CREATE TABLE IF NOT EXISTS User (objectId INTEGER PRIMARY KEY AUTOINCREMENT, createdAt DATE, updatedAt DATE, firstName TEXT NOT NULL, lastName TEXT, age INTEGER NOT NULL, birthday DATE, gender TEXT, email TEXT NOT NULL, registerNumber INTEGER NOT NULL, Address_objectId INTEGER NOT NULL)
```

> _Note:_ Reflect create automatically `objectId`, `createdAt` and `updatedAt`. `The objectId` is an Integer auto increment and is primary key default.

#### Optional object
Type optional Supported:

| Optional    | [x] |
| ----------- | --- |
| `String`    | [x] |
| `NSString`  | [x] |
| `NSInteger` | [x] |
| `NSNumber`  | [x] |
| `Date`      | [x] |
| `Data`      | [x] |

If object is an optional, automatically remove `NOT NULL` on Query

#### UnRegister Object
``` swift
User.unRegister()

//DROP TABLE User
```

#### Indexes
The index name is generated automatically based on the table and column names

  - `unique` adds a `UNIQUE` constraint to the index. Default: `false`.
  ``` swift
  User.index("registerNumber", unique: true)
  User.index("firstName")

  // CREATE UNIQUE INDEX IF NOT EXISTS index_User_on_registerNumber ON User (registerNumber)
  // CREATE INDEX IF NOT EXISTS index_User_on_firstName ON User (firstName)
  ```

## Save Object
We can insert rows into a table by calling a Reflect Object `pin` function.
``` swift

let address = Address()
address.street = "Highland Drive Temple Hills"
address.number = 226
address.state  = "MD"
address.zip    = 20748

address.pin()
// INSERT INTO Address ( createdAt, updatedAt, street, number, state, zip ) VALUES ('2016-11-14 19:40:11', '2016-11-14 19:40:11', 'Highland Drive Temple Hills', 226, 'MD', 20748)

```

If the object contains an object Reflect property, when executing the function `pin`, Reflect automatically creates a reference by adding the objectId of the property.
``` swift

let user = User()
user.firstName = "Kanisha"
user.lastName  = "Classen"
user.age       = 69
user.birthday  = '1947-01-23 21:46:23'.date
user.gender = "female"
user.email = "kanisha.classen@test.com"
user.registerNumber = 9798
user.address = address

//INSERT INTO User ( createdAt, updatedAt, firstName, lastName, age, birthday, gender, email, registerNumber, Address_objectId ) VALUES ('2016-11-14 19:44:23', '2016-11-14 19:44:23', 'Kanisha', 'Classen', 69, '1947-01-23 21:46:23', 'female', 'kanisha.classen@test.com', 9798, 1)

```

> _Note:_ If exist an value to objectId to object Reflect, when executing the function `pin` the Reflect going to change object using `update`.

## Remove Object
We can delete an row a table with `unPin` function.
``` swift
let user = User()
user.objectId = 2

user.unPin()
```
To remove all object, we can user the method `clear`
``` swift
User.clean()
```

## Transactions
Using the `transaction` function, we can run a series of statements in a transaction. If a single statement fails or the block throws an error, the changes will be rolled back.
``` swift
let address = Address()
let user = User()
User.transaction {
  address.number = 101
  address.street = "Alpha Village"
  address.state  = "NY"
  address.zip    = 10203
  address.pin()
            
  user.firstName = "Bruno"
  user.lastName  = "Fernandes"
  user.age       = 29
  user.gender    = "male"
  user.email     = "bruno@test.me"
  user.registerNumber = 987654
  user.address = address
  
  let cal = Calendar.current
  user.birthday = cal.date(byAdding: .day, value: -Int(arc4random_uniform(30)), to: Date())
  user.birthday = cal.date(byAdding: .month, value: -Int(arc4random_uniform(12)), to: user.birthday!)
  user.birthday = cal.date(byAdding: .year, value: -user.age, to: user.birthday!)
  
  user.pin()
}

// BEGIN DEFERRED TRANSACTION
// INSERT INTO Address ( createdAt, updatedAt, street, number, state, zip ) VALUES ('2016-11-14 21:17:15', '2016-11-14 21:17:15', 'Alpha Village', 101, 'NY', 10203)
// INSERT INTO User ( createdAt, updatedAt, firstName, lastName, age, birthday, gender, email, registerNumber, Address_objectId ) VALUES ('2016-11-14 21:17:15', '2016-11-14 21:17:15', 'Bruno', 'Fernandes', 29, '1986-12-26 21:17:15', 'male', 'bruno@test.me', 987654, 21)
// COMMIT TRANSACTION
```

## Query syntax

#### Basic Filter

We can find specific id with `findById` function.
``` swift
let user = User.findById(2)
//SELECT * FROM User WHERE User.objectId = 2
```
or if exist object instance we can use `fetch` function.
``` swift
let user = User()
user.objectId = 2
user.fetch()
//SELECT * FROM User WHERE User.objectId = 2
```

include another object type `Reflect`, this case the fetch add an inner as default to include object
```
user.fetch(include: Address.self)
//SELECT Address.objectId AS 'Address.objectId', Address.createdAt AS 'Address.createdAt', Address.updatedAt AS 'Address.updatedAt', Address.street AS 'Address.street', Address.number AS 'Address.number', Address.state AS 'Address.state', Address.zip AS 'Address.zip', User.* FROM User INNER JOIN Address ON User.Address_objectId = Address.objectId WHERE User.objectId = 2
```

#### Filters
Reflect filters rows using a Query with `filter` function. 
Support operator:

| Operator      | [x] |
| ------------- | --- |
| `Equals`      | [x] |
| `NotEquals`   | [x] |
| `GreaterThan` | [x] |
| `LessThan`    | [x] |
| `In`          | [x] |
| `NotInt`      | [x] |
| `Is`          | [x] |
| `Like`        | [x] |
| `NotLike`     | [x] |


  - `equals`
    ``` swift
    var query = User.query()

    query.filter("age", .equals, value: 25)
    
    var users = query.findObject()
    //SELECT * FROM User WHERE age = 25
    ```

  - `notEquals`
    ``` swift
    var query = User.query()

    query.filter("gender", .notEquals, value: "male")
    
    var users = query.findObject()
    //SELECT * FROM User WHERE gender != 'male'
    ```

  - `greaterThan`
    ``` swift
    var query = User.query()

    query.filter("registerNumber", .greaterThan, value: 5000)
    
    var users = query.findObject()
    //SELECT * FROM User WHERE registerNumber > 5000
    ```

  - `lessThan`
    ``` swift
    var query = User.query()

    query.filter("registerNumber", .lessThan, value: 4500)
    
    var users = query.findObject()
    //SELECT * FROM User WHERE registerNumber < 4500
    ```

  - `in`
    ``` swift
    var query = Address.query()

    query.filter("state", .in, value: "MI", "GA", "LI")
    
    var addresses = query.findObject()
    //SELECT * FROM Address WHERE state IN ('MI' , 'GA' , 'LI')
    ```

  - `notIn`
    ``` swift
    var query = Address.query()

    query.filter("number", .notIn, value: 105, 226, 760, 728)
    
    var addresses = query.findObject()
    //SELECT * FROM Address WHERE number NOT IN (105 , 226 , 760 , 728)
    ```

  - `is`
    ``` swift
    var query = Address.query()

    query.filter("updatedAt", .is, value: nil)
    
    var addresses = query.findObject()
    //SELECT * FROM Address WHERE updatedAt IS NULL
    ```

  - `like`
    ``` swift
    //Ex: 'A%' '%A' '%a%'

    var query = query = User.query()

    query.filter("firstName", .like, value: "A%")
    
    users = query.findObject()
    //SELECT * FROM User WHERE firstName LIKE 'A%'
    ```

  - `notLike`
    ``` swift
    //Ex: 'A%' '%A' '%a%'

    var query = query = User.query()

    query.filter("firstName", .notLike, value: "%mi%")
    
    users = query.findObject()
    //SELECT * FROM User WHERE firstName NOT LIKE '%mi%'
    ```

  - `between`
    ``` swift
    var query = User.query()

    query.filter("age", .between, value: 20, 30)

    users = query.findObject()
    //SELECT * FROM User WHERE age BETWEEN 20 AND 30
    ```

#### Selecting Columns
By default, Query select every column of the result set (using `SELECT *`). We can use the `fields` function to return specific columns instead.
``` swift
var query = User.query()

query.fields("objectId", "firstName", "lastName", "age")

query.findObject()
//SELECT objectId, firstName, lastName, age FROM User
```

#### Aggregation
Query come with a number of functions that quickly return aggregate scalar values from the table.

  - `count`
    ``` swift
    var query = User.query()

    let result = query.count()
    //SELECT COUNT(*) AS count FROM User
    ```

  - `sum`
    ``` swift
    var query = User.query()

    let result = query.sum("age")
    //SELECT SUM(age) AS value FROM User
    ```

  - `average`
    ``` swift
    var query = User.query()

    let result = query.average("age")
    //SELECT AVG(age) AS average FROM User
    ```

  - `max`
    ``` swift
    var query = User.query()

    let result = query.max("birthday") as! String
    //SELECT MAX(birthday) AS maximum FROM User
    ```

  - `min`
    ``` swift
    var query = User.query()

    let result = query.min("birthday") as! String
    //SELECT MIN(birthday) AS minimum FROM User
    ```
    
  - `distinct`
    ``` swift
    var query = User.query()
    
    users = query.fields("age").distinct().findObject()
    //SELECT DISTINCT age FROM User;
    ```

#### Sort
We can pre-sort returned rows using a Query with `sort` function.

Type Sort : Asc and Desc.

``` swift
var query = User.query()
var users = query.sort("age", .asc).findObject()

//SELECT * FROM User ORDER BY age ASC
```

#### Limit and Offset
We can limit and offset returned rows using a Query, `limit` function and `offset` have parameter default is equal 1.
``` swift
var query = User.query()
var users = query.filter("gender", .equals, value: "female")
                 .sort("age", .desc)
                 .limit(3)
                 .offset(2)
                 .findObject()
                 
//SELECT * FROM User WHERE gender = 'female' ORDER BY age DESC LIMIT 3 OFFSET 2
```

#### And / Or
We can create an block to filter that need condition `or` or `and`. The Reflect create all content on block with key `and` or `or` depends of function.
``` swift
var query = User.query()
        
query.filter("gender", .equals, value: "female").or { q in
     q.filter("age", .greaterThan, value: 70)
           .filter("age", .lessThan, value: 20)
}
        
users = query.findObject()
//SELECT * FROM User WHERE gender = 'female' AND (age > 70 OR age < 20)
```

#### Joining Other Tables
We can join tables using a Query `join` function.

The `join` function takes a Query object (for the table being joined on), a join condition (`on`), and is prefixed with an optional join type (default: `.inner`).
When joining tables, column names can become ambiguous and to fix this, Reflect adds a prefix with the table name.

``` swift
var query = User.query()
        
query.join(Address.self)
query.or { q in
    q.filter("gender", .equals, value: "female").filter("age", .greaterThan, value: 50)
}.and { q in
    q.filter("Address.state", .in, value: "MI", "GA", "LI")
}
        
users = query.findObject()
//SELECT Address.objectId AS 'Address.objectId', Address.createdAt AS 'Address.createdAt', Address.updatedAt AS 'Address.updatedAt', Address.street AS 'Address.street', Address.number AS 'Address.number', Address.state AS 'Address.state', Address.zip AS 'Address.zip', User.* FROM User INNER JOIN Address ON User.Address_objectId = Address.objectId WHERE (gender = 'female' OR age > 50) AND (Address.state IN ('MI' , 'GA' , 'LI'))
```

## Logging
Adding this function, we can monitor all instruction sql in real-time
``` swift
Reflect.settings.log { (SQL:String) in
  print("\n Instruction sql -- ", SQL, "\n")
}
```

(The MIT License)

Copyright (c) 2016 Bruno Fernandes (<bruno.fernandesbfs@gmail.com>)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
