import Foundation

/// An instance of a KeyVine. You don't need to instantiate this if you plan to use the
/// property wrappers, which create and cache their own instances when needed.
public struct KeyVine: Sendable {
    /// Use this to access values from the keychain using plain property syntax.
    ///
    /// ```
    /// @KeyVine.OptionalProperty(key: "name_for_my_data", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
    /// var storedData: Data?
    ///
    /// if let storedData {
    ///     let myText = String(data: storedData, encoding: .utf8)
    ///     print(myText)
    /// }
    /// ```
    @propertyWrapper
    public struct OptionalProperty<Value: KeyVineDataConvertible> {
        let key: String
        var vine: KeyVine

        public init(key: String, appIdentifier: String, teamId: String, accessibility: Accessibility) {
            self.key = key
            vine = KeyVine(appIdentifier: appIdentifier, teamId: teamId, accessibility: accessibility)
        }

        public var wrappedValue: Value? {
            get { vine[key] }
            set { vine[key] = newValue }
        }
    }

    /// Use this to access values from the keychain using plain property syntax, using a default value if none is found in the Keychain.
    ///
    /// ```
    /// @KeyVine.Property(key: "name_for_my_data", appIdentifier: "com.myApp.identifier", teamId: "ABC1234567", defaultValue: "Hello world!")
    /// var greeting: String
    ///
    /// print(greeting)
    /// ```
    @propertyWrapper
    public struct Property<Value: KeyVineDataConvertible> {
        let key: String
        var vine: KeyVine
        let defaultValue: Value

        public init(key: String, appIdentifier: String, teamId: String, accessibility: Accessibility, defaultValue: Value) {
            self.key = key
            self.defaultValue = defaultValue
            vine = KeyVine(appIdentifier: appIdentifier, teamId: teamId, accessibility: accessibility)
        }

        public var wrappedValue: Value {
            get { vine[key] ?? defaultValue }
            set { vine[key] = newValue }
        }
    }

    /// An error that can be thrown from the read and write methods. Please note that, beacuse of Swift language constraints,
    /// the property and subscript syntax cannot throw errors.
    public enum KeyVineError: LocalizedError {
        case readFailure(OSStatus)
        case writeFailure(OSStatus)

        public var errorDescription: String? {
            switch self {
            case let .readFailure(status):
                if let errorMessage = SecCopyErrorMessageString(status, nil) {
                    "Keychain read failed with error \(status): \(errorMessage)"
                } else {
                    "Keychain read failed with error \(status)"
                }
            case let .writeFailure(status):
                if let errorMessage = SecCopyErrorMessageString(status, nil) {
                    "Keychain write failed with error \(status): \(errorMessage)"
                } else {
                    "Keychain write failed with error \(status)"
                }
            }
        }
    }

    /// The accessibility value of the stored values. If none if provided `afterFirstUnlock` is used, which is the most permissive value.
    public enum Accessibility {
        /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
        case whenPasscodeSetThisDeviceOnly
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        case whenUnlockedThisDeviceOnly
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        case whenUnlocked
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        case afterFirstUnlockThisDeviceOnly
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        case afterFirstUnlock

        var cfValue: CFString {
            switch self {
            case .afterFirstUnlock:
                kSecAttrAccessibleAfterFirstUnlock
            case .afterFirstUnlockThisDeviceOnly:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .whenPasscodeSetThisDeviceOnly:
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            case .whenUnlocked:
                kSecAttrAccessibleWhenUnlocked
            case .whenUnlockedThisDeviceOnly:
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            }
        }
    }

    private nonisolated(unsafe) let templateQuery: [CFString: Any]

    /// Initialise a key vine using a pair of identifiers. They can in theory be anything, but for sandboxed and app store apps,
    /// or apps that use keychain sharing, this should be the same as the app's identifier and the team ID which is used to sign the app.
    ///
    /// ```
    /// let keyVine = KeyVine(appIdentifier: "com.myApp.identifier", teamId: "ABC1234567")
    /// ...
    /// ```
    public init(appIdentifier: String, teamId: String, accessibility: Accessibility = .afterFirstUnlock) {
        templateQuery = [kSecClass: kSecClassGenericPassword,
                         kSecAttrService: appIdentifier,
                         kSecUseDataProtectionKeychain: kCFBooleanTrue!,
                         kSecAttrAccessible: accessibility.cfValue,
                         kSecAttrAccessGroup: "\(teamId).\(appIdentifier)"]
    }

    /// Reads a `Data` object from a keychain for a specific key.
    ///
    /// ```
    /// let storedData = keyVine["name_for_my_data"]
    /// let myText = String(data: storedData, encoding: .utf8)
    /// print(myText)
    /// ```
    /// - Parameter key: The key of the entry to read
    /// - Returns: The store data for this key, or `nil` if it does not exist
    public func read(from key: String) throws -> Data? {
        var query = templateQuery
        query[kSecAttrAccount] = key
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = kCFBooleanTrue

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        switch status {
        case errSecSuccess:
            return itemCopy as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeyVineError.readFailure(status)
        }
    }

    /// Stores a `Data` object in the keychain from a specific key. If the data is `nil` the item is removed. If the item already exists, it is replaced.
    ///
    /// ```
    /// let myData = try Data(contentsOf: ...)
    /// keyVine["name_for_my_data"] = myData
    /// ```
    /// - Parameters:
    ///   - key: The key of the entry to write or remove
    ///   - data: The data to write or replace for the specific key, or `nil` to remove the entry from the keychain
    public func write(data: Data?, to key: String) throws {
        var query = templateQuery
        var status: OSStatus

        query[kSecAttrAccount] = key

        if let data {
            query[kSecValueData] = data
            status = SecItemAdd(query as CFDictionary, nil)

            switch status {
            case errSecDuplicateItem:
                query[kSecValueData] = nil
                status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)

            default:
                break
            }

        } else {
            status = SecItemDelete(query as CFDictionary)
            switch status {
            case errSecItemNotFound, errSecSuccess:
                return
            default:
                break
            }
        }

        if status != errSecSuccess {
            throw KeyVineError.writeFailure(status)
        }
    }

    /// Read and write values using subscript syntax
    ///
    /// ```
    /// let myInfo: MyInfo = keyVine["my_info_key"]
    /// ...
    /// keyVine["my_info_key"] = someOtherInfo
    /// ```
    public subscript<T: KeyVineDataConvertible>(key: String) -> T? {
        get { try! T(keyVineData: read(from: key)) }
        set { try! write(data: newValue?.keyVineData, to: key) }
    }
}
