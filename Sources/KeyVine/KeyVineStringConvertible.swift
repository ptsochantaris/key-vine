import Foundation

/// This protocol is convenient for conforming things that already implement `LosslessStringConvertible`
/// For example KeyVine already conforms `Bool`, `Int`, `Float`, and `Double` to this protocol, but you can add it to anything
/// which is `LosslessStringConvertible`.
///
/// ```
/// extension UInt32: KeyVineStringConvertible {}
///
/// @KeyVine.Property(key: "my_stored_number_key", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
/// var myStoredCounter: UInt32?
/// ...
///
/// myStoredCounter = (myStoredCounter ?? 0) + 1
/// print(myStoredCounter)
/// ```
public protocol KeyVineStringConvertible: KeyVineDataConvertible, LosslessStringConvertible {}

public extension KeyVineStringConvertible {
    init?(keyVineData: Data?) {
        guard let string = String(keyVineData: keyVineData) else {
            return nil
        }
        self.init(string)
    }

    var keyVineData: Data? {
        description.keyVineData
    }
}

extension Bool: KeyVineStringConvertible {}
extension Int: KeyVineStringConvertible {}
extension Float: KeyVineStringConvertible {}
extension Double: KeyVineStringConvertible {}
