//      \/[]\/
//        /\
//       |  |  +----+
//       |  |  |    |
//       |  |  `----'
//       |  |
//       |  |
//        \/
//

import Foundation


/// Represents the settings for a single named experiment which knows how to store its settings.
public struct Experiment {

    // MARK: General Configuration

    /// The `UserDefaults` instance for persistence of experiment settings. This should
    /// usually be overridden to point to a store visible by the app and its extensions,
    /// but it will point to `UserDefaults.standard` unless you provide a different one.
    public static var defaults = UserDefaults.standard

    /// Method for logging debug info. Defaults to `print`. Overwrite this with a function
    /// that ties into your logging system.
    public static var debugLog: (String) -> Void = { print($0) }


    // MARK: Public API

    /// Name for the experiment. By convention, it should be a `camelCaseValue`.
    /// It will be altered for use as a key in storage.
    public private(set) var name: String

    /// Indicates if this experiment is active. Setting it will persist the change in the store.
    public var enabled: Bool {
        get { return store.bool(forKey: storageKey) }
        set { store.set(newValue, forKey: storageKey) }
    }

    /// Indicates if this experiment has ever been given a value.
    public var exists: Bool {
        return store.object(forKey: storageKey) != nil
    }

    /// Removes all persisted settings for this experiment.
    public func remove() {
        store.removeObject(forKey: storageKey)
        Experiment.debugLog("at=experiment-remove name=\(name)")
    }


    // MARK: Private API

    /// Location to load and save values for _this_ experiment.
    private var store: UserDefaults

    /// A variation of `name` to reduce the likelihood of collisions in UserDefaults.
    private var storageKey: String {
        return Experiment.storageKey(for: name)
    }

    /// Creates a named experiment which knows how to store its settings. The name will
    /// be altered before storing values in the provided `UserDefaults` instance to
    /// reduce the likelihood of name collisions, so feel free to use clear names.
    ///
    /// - Note: Made private to allow for possible future optimizations.
    ///
    /// - Parameters:
    ///   - name: The name of the experiment. Use a clear `camelCaseName` (not enforced).
    ///   - store: Used to store this experiment's settings. Default is `Experiment.defaults`.
    private init(named name: String, store: UserDefaults = Experiment.defaults) {
        self.name = name
        self.store = store
    }

    /// Calculate a storage key from a name. Used by instances, and during configuration by URLs.
    private static func storageKey(for name: String) -> String {
        return "\(name)_experiment"
    }

}


extension Experiment {

    // MARK: Static methods

    /// Get the experiment with the given name. Its settings will be loaded from the current
    /// `Experiment.defaults`.
    ///
    /// - Note: Prefered to `init` to allow for possible future optimizations by keeping client
    ///         code from directly relying on the initializers.
    ///
    /// - Parameter name: The name of the experiment. Use a clear `camelCaseName` (not enforced).
    /// - Returns: The named experiment.
    public static func named(_ name: String) -> Experiment {
        return Experiment(named: name)
    }

    /// Set experiment values from a URL. Useful for giving testers specialized URLs to
    /// enable experiments on a device.
    ///
    /// Handle incoming URL:
    ///
    ///    func application(_ app: UIApplication, open url: URL, options: ...) -> Bool {
    ///        if Experiment.configure(from: url) {
    ///            return true
    ///        }
    ///        // Your custom URL code
    ///        return false
    ///    }
    ///
    /// Turn it on:
    ///
    ///     myapp://experiments/configure?visibleResponseTime=true
    ///
    /// Turn it off:
    ///
    ///     myapp://experiments/configure?visibleResponseTime=false
    ///
    /// Delete it:
    ///
    ///     myapp://experiments/configure?visibleResponseTime=
    ///
    @discardableResult
    public static func configure(from url: URL?, host: String = "experiments") -> Bool {
        guard let url = url else { return false }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
        guard let givenHost = components.host, givenHost == host else { return false }

        let pathItems = components.path.components(separatedBy: "/").filter { $0 != "" }
        guard let path = pathItems.first, path == "configure" else { return false }

        enum URLAction {
            case remove(String)
            case set(Bool, String)
        }

        let actions: [URLAction] = components.queryItems!.compactMap { item in
            guard let value = item.value else {
                return .remove(item.name)
            }
            if let bool = Bool(value) {
                return .set(bool, item.name)
            }
            debugLog("at=experiment-from-url action=set error=value-not-boolean name=\(item.name) value=\(value)")
            return nil
        }

        // A non-boolean value was found
        if actions.count != components.queryItems!.count {
            return false
        }

        for action in actions {
            switch action {
            case let .remove(name):
                let key = storageKey(for: name)
                defaults.removeObject(forKey: key)
                debugLog("at=experiment-from-url action=remove name=\(name)")
            case let .set(value, name):
                let key = storageKey(for: name)
                defaults.set(value, forKey: key)
                debugLog("at=experiment-from-url action=set name=\(name) value=\(value)")
            }
        }

        return true
    }

}
