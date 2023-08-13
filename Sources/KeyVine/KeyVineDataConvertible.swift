import Foundation

/// A protocol that allows a type to serialise itself from/to `Data` which is then used by KeyVine to store into the Keychain.
public protocol KeyVineDataConvertible {
    /// Should return a data representation of itself.
    var keyVineData: Data? { get }
    
    /// Initialise a new instance of this type using the provided data.
    init?(keyVineData: Data?)
}

/// Conforms `Date` to ``KeyVineDataConvertible`` so it can be used directly with KeyVine.
///
/// ```
/// @KeyVine.Property(key: "my_stored_date_key", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
/// var myStoredDate: Date?
///
/// if let myStoredDate {
///     print(myStoredDate)
/// } else {
///     myStoredDate = Date.now
/// }
/// ```
extension Date: KeyVineDataConvertible {
    public init?(keyVineData: Data?) {
        guard let timestamp = TimeInterval(keyVineData: keyVineData) else {
            return nil
        }
        self.init(timeIntervalSinceReferenceDate: timestamp)
    }

    public var keyVineData: Data? {
        timeIntervalSinceReferenceDate.keyVineData
    }
}

/// Conforms `String` to ``KeyVineDataConvertible`` so it can be used directly with KeyVine.
///
/// ```
/// @KeyVine.Property(key: "my_stored_text_key", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
/// var myStoredText: String?
///
/// if let myStoredText {
///     print(myStoredDate)
/// } else {
///     myStoredText = "Hello world!"
/// }
/// ```
extension String: KeyVineDataConvertible {
    public init?(keyVineData: Data?) {
        guard let keyVineData else { return nil }
        self.init(data: keyVineData, encoding: .utf8)
    }

    public var keyVineData: Data? {
        data(using: .utf8)
    }
}

/// Conforms `Data` to ``KeyVineDataConvertible`` so it can be used directly with KeyVine.
/// Does very little, as it just initialises itself as the data, and returns itself when data is requested.
extension Data: KeyVineDataConvertible {
    public init?(keyVineData: Data?) {
        guard let keyVineData else {
            return nil
        }
        self = keyVineData
    }

    public var keyVineData: Data? {
        self
    }
}
