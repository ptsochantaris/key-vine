<img src="https://ptsochantaris.github.io/trailer/KeyVineLogo.webp" alt="Logo" width=256 align="right">

# KeyVine

A Keychain access wrapper in Swift, because the world needs more of these

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fptsochantaris%2Fkey-vine%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ptsochantaris/key-vine) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fptsochantaris%2Fkey-vine%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ptsochantaris/key-vine)

It is currently used in [Trailer](https://github.com/ptsochantaris/trailer)

Detailed docs [can be found here](https://swiftpackageindex.com/ptsochantaris/key-vine/documentation)

## Overview

The aim of KeyVine is to be a simple and very reusable Keychain access wrapper for Swift on Apple platforms.

There are far more evolved and fully featured packages out there to do this, but in my projects I keep finding the need for a super simple way to just create a few "Keychain properties" and access them with the minimum of fuss, with the most common defaults. This does exactly that.

Initialise it with an identifier for the app and the team ID.

There are various ways to use it:

### Reading and writing raw data

Read and write simple `Data` blocks

```
let keyVine = KeyVine(appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")

let storedData = try keyVine.read(fro,: "name_for_my_data")
let myText = String(data: storedData, encoding: .utf8)
print(myText)

let myData = try Data(contentsOf: ...)
try keyVine.write(myData, to: "name_for_my_data")
```

Using the subscript operator

```
let keyVine = KeyVine(appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")

let storedData = keyVine["name_for_my_data"]
let myText = String(data: storedData, encoding: .utf8)
print(myText)

let myData = try Data(contentsOf: ...)
keyVine["name_for_my_data"] = myData
```

Using the property wrapper

```
@KeyVine.Property(key: "name_for_my_data", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
var storedData: Data?

if let storedData {
    let myText = String(data: storedData, encoding: .utf8)
    print(myText)
}
```

### Reading and writing types

KeyVine already supports `String`, `Date`, `Bool`, `Int`, `Float` and `Double` but you can also conform any type to `KeyVineDataConvertible`

If the type already conforms to `LosslessStringConvertible` you can just add `KeyVineStringConvertible` instead without needing to create extra serialisation code.

```
extension MyInfo: KeyVineDataConvertible {
    init?(keyVineData: Data?) {
        ... // initialise from data
    }
    
    var asKeyVineData: Data? {
        let data = ... // Serialise to data
        return data
    }
}
```

Using the subscript operator

```
let keyVine = KeyVine(appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")

let myInfo: MyInfo = keyVine["my_info_key"]

...

keyVine["my_info_key"] = myInfo
```

Using the property wrapper

Provide a default for a non-optional property
```
@KeyVine.Property(key: "my_info_key", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567", defaultValue: "Hello world!")
var greeting: String

print(greeting) // 'Hello world!'
```
Or not
```
@KeyVine.OptionalProperty(key: "my_info_key", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
var storedInfo: MyInfo?

if let storedInfo {
    doStuff(with: storedInfo)
}

...

storedInfo = MyInfo()
```

### License
Copyright (c) 2023 Paul Tsochantaris. Licensed under the MIT License, see LICENSE for details.
