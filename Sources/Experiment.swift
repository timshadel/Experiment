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


/// Represents an experimental feature within the app that can be enabled and disabled.
///
/// The settings for each experiment are stored in a `UserDefaults` suite, and typically
/// you should configure it to be a suite reachable by the app and all its extensions.
///
///     class AppDelegate: UIResponder, UIApplicationDelegate {
///         func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
///            Experiment.defaults = UserDefaults(suiteName: "group.com.example.myapp.all")!
///         }
///     }
///
/// You'll define named experiments in an extension on `Experiment`, then refer to
/// individual experiments within UI code to make decisions about display or processing.
///
///     extension Experiment {
///         // See: https://goodui.org/fastforward/patterns/24/
///         static var visibleResponseTime = Experiment.named("visibleResponseTime")
///     }
///
///     class SupportViewController: UIViewController {
///         func configureView() {
///            if Experiment.visibleResponseTime.enabled {
///                view.addSubview(self.responseTimeLabel)
///            }
///         }
///     }
///
/// You may choose to turn on an experiment for a user any way you want. This may be
/// in response to an API call, or even a button click on the user interface.
///
///     class BetaViewController: UIViewController {
///         func toggleVisibleResponseTime() {
///            Experiment.visibleResponseTime.enabled = !Experiment.visibleResponseTime.enabled
///         }
///     }
///
/// To use a specific setting during development in Xcode, edit your scheme and add a value to
/// "Arguments Passed on Launch" and then your app will act as if the setting was enabled, but
/// without storing that setting in the Simulator itself.
///
///     `-visibleResponseTime_experiment YES`
///
/// When your need for an experiment is done, do the following:
///
///   1. Remove all code that uses the value, and delete the code branch that is no longer valid.
///   2. Remove the static var in your extension of `Experiment`
///   3. In migration code, call `Experiment.named("visibleResponseTime").remove()`.
///
public struct Experiment {

    // MARK: Public Properties

    /// The `UserDefaults` instance for persistence of experiment settings. This should
    /// usually be overridden to point to a store visible by the app and its extensions.
    public static var defaults = UserDefaults.standard

    /// Name for the experiment. By convention, it should be a `camelCaseValue`.
    /// It will be altered for use as a key in storage.
    public private(set) var name: String

    /// Indicates if this experiment is active. Setting it will persist the change in the store.
    public var enabled: Bool {
        get { return store.bool(forKey: storageKey) }
        set { store.set(newValue, forKey: storageKey) }
    }


    // MARK: Public Methods

    /// Get the experiment with the given name. Its settings will be loaded from the current
    /// `Experiment.defaults`.
    ///
    /// - Parameter name: The name of the experiment. Use a clear `camelCaseName` (not enforced).
    /// - Returns: The named experiment.
    public static func named(_ name: String) -> Experiment {
        return Experiment(named: name)
    }

    /// Removes all persisted settings for this experiment.
    public func remove() {
        store.removeObject(forKey: storageKey)
    }


    // MARK: Private properties

    /// Location to load and save values for _this_ experiment.
    private var store: UserDefaults

    /// A variation of `name` to reduce the likelihood of collisions in UserDefaults.
    private var storageKey: String {
        return "\(name)_experiment"
    }


    // MARK: Private Initialization

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

}
