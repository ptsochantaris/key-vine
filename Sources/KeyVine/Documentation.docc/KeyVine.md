# ``KeyVine``

A Keychain access wrapper in Swift, because the world needs more of these

## Overview

Tha aim of KeyVine is to be a simple and very reusable Keychain access wrapper for Swift on Apple platforms.

There are far more evolved and fully featured packages out there to do this, but in my projects I keep finding the need for a super simple way to just create a few "Keychain properties" and access them with the minimum of fuss, with the most common defaults. This does exactly that.

Initialise it with an identifier for the app and the team ID. There are various ways to use it:

### Reading and writing raw `Data`

```
    // Read and write simple `Data` blocks

    let keyVine = KeyVine(appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")

    let storedData = try keyVine.read(fro,: "name_for_my_data")
    let myText = String(data: storedData, encoding: .utf8)
    print(myText)

    let myData = try! Data(contentsOf: ...)
    try keyVine.write(myData, to: "name_for_my_data")
```

```
    // Using the subscript operator

    let keyVine = KeyVine(appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")

    let storedData = keyVine["name_for_my_data"]
    let myText = String(data: storedData, encoding: .utf8)
    print(myText)

    let myData = try! Data(contentsOf: ...)
    keyVine["name_for_my_data"] = myData
```

```
    // Using the property wrapper

    @KeyVine.Property(key: "name_for_my_data", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
    var storedData: Data?

    if let storedData {
        print(String(data: storedData, encoding: .utf8)
    }
```

### Reading and writing types

```
    // Conform a type to KeyVineDataConvertible (or KeyVineStringConvertible, whatever makes more sense)

    extension MyInfo: KeyVineDataConvertible {
        init?(keyVineData: Data?) {
            ... // initialise from data
        }
        
        var asKeyVineData: Data? {
            let data = ... // Serialise to data
            return data
        }
    }
}
```

```
    // Using the subscript operator

    let keyVine = KeyVine(appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")

    let myInfo: MyInfo = keyVine["my_info_key"]

    ...

    keyVine["my_info_key"] = myInfo
```

```
    // Using the property wrapper

    @KeyVine.Property(key: "my_info_key", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
    var storedInfo: MyInfo?

    if let storedInfo {
        doStuff(with: storeInfo)
    }

    ...

    storedInfo = MyInfo()
```