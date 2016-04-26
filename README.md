# Reflect

Reflect is an ActiveRecord framework, elegant and simple that use the SQLite in Swift

- [x] Easy configuration
- [x] Simple syntax

## Usage

Configuration

``` swift
import ReflectFramework

class User: Reflect {
    var firstName:String
    var lastName :String
    var age:Int
    var email:String
    
    required init() {
        firstName = ""
        lastName  = ""
        age       = 0
        email     = ""
    }
  }
```

Register object
``` swift

User.register()

```

Save Object
``` swift

let user = User()
user.firstName = "Bruno"
user.lastName  = "Fernandes"
user.age       = 29
user.email = "bruno@brunofernandes.me"

user.pin()

```

Remove Object
``` swift
let user = User()
user.objectId = 2

user.unPin()

```
