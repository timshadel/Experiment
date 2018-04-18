//      \/[]\/
//        /\
//       |  |  +----+
//       |  |  |    |
//       |  |  `----'
//       |  |
//       |  |
//        \/
//

import XCTest
@testable import Experiment

// describe Experiment

// when it is named
class WhenExperimentIsNamed: XCTestCase {

    // Use unique experiment names to keep tests isolated.

    // it can be enabled
    func testExperimentCanBeEnabled() {
        let named = "enableTest"

        var setter = Experiment.named(named)
        XCTAssertFalse(setter.exists)
        XCTAssertFalse(setter.enabled)
        setter.enabled = true

        var getter = Experiment.named(named)
        XCTAssertTrue(getter.exists)
        XCTAssertTrue(getter.enabled)
        getter.remove()
    }

    // it can be disabled
    func testExperimentCanBeDisabled() {
        let named = "disableTest"

        var setter = Experiment.named(named)
        XCTAssertFalse(setter.exists)
        XCTAssertFalse(setter.enabled)
        setter.enabled = false

        var getter = Experiment.named(named)
        XCTAssertTrue(getter.exists)
        XCTAssertFalse(getter.enabled)
        getter.remove()
    }

    // it can be removed
    func testExperimentCanBeRemoved() {
        let named = "removeTest"

        var setter = Experiment.named(named)
        XCTAssertFalse(setter.exists)
        setter.enabled = true

        var remover = Experiment.named(named)
        XCTAssertTrue(remover.exists)
        XCTAssertTrue(remover.enabled)
        remover.remove()

        let getter = Experiment.named(named)
        XCTAssertFalse(getter.exists)
    }

    // it name does not collide with UserDefaults
    func testExperimentNameDoesNotCollideWithUserDefaults() {
        let name = "noNameCollision"
        let value = "someValue"
        UserDefaults.standard.set(value, forKey: name)
        var experiment = Experiment.named(name)
        experiment.enabled = true
        // If the experiment overwrote the value, then the values wouldn't match.
        XCTAssertEqual(value, UserDefaults.standard.string(forKey: name))
        XCTAssertTrue(Experiment.named(name).enabled)
    }

}


// when it is configured with a URL
class WhenExperimentIsConfiguredWithAURL: XCTestCase {

    // it can be configured from a good URL
    func testExperimentCanBeConfiguredFromAGoodURL() {
        let named = "urlConfig"
        var experiment = Experiment.named(named)
        XCTAssertFalse(experiment.enabled)
        Experiment.configure(from: URL(string: "myapp://experiments/configure?\(named)=true"))
        XCTAssertTrue(experiment.enabled)
        experiment.remove()
    }

    // it can be configured with a custom host
    func testExperimentCanBeConfiguredWithACustomHost() {
        XCTAssertTrue(Experiment.configure(from: URL(string: "myapp://customHost/configure?configFailure=false"), host: "customHost"))
    }

    // it can remove an experiment by URL with an empty query value
    func testExperimentCanRemoveAnExperimentByURLWithAnEmptyQueryValue() {
        let named = "emptyValue"
        var experiment = Experiment.named(named)
        XCTAssertFalse(experiment.exists)
        experiment.enabled = false
        XCTAssertTrue(experiment.exists)
        Experiment.configure(from: URL(string: "myapp://experiments/configure?\(named)"))
        XCTAssertFalse(experiment.exists)
    }

}


// when it configuration fails
class WhenExperimentConfigurationFails: XCTestCase {

    // it fails with a nil URL
    func testExperimentFailsWithANilURL() {
        XCTAssertFalse(Experiment.configure(from: nil))
    }

    // it fails with a file URL
    func testExperimentFailsWithAFileURL() {
        XCTAssertFalse(Experiment.configure(from: URL(string: "file:///../../badURL")))
    }

    // it fails with a bad host
    func testExperimentFailsWithABadHost() {
        XCTAssertFalse(Experiment.configure(from: URL(string: "myapp://badhost/configure?configFailure=true")))
    }

    // it fails with a negative port
    func testExperimentFailsWithANegativePort() {
        // This is the best way to cause URLComponents to be `nil`
        XCTAssertFalse(Experiment.configure(from: URL(string: "myapp://experiments:-20/?configFailure=true")))
    }

    // it fails with a missing path
    func testExperimentFailsWithAMissingPath() {
        XCTAssertFalse(Experiment.configure(from: URL(string: "myapp://experiments/?configFailure=true")))
    }

    // it fails with a bad path
    func testExperimentFailsWithABadPath() {
        XCTAssertFalse(Experiment.configure(from: URL(string: "myapp://experiments/other?configFailure=true")))
    }

    // it fails when any setting is not boolean
    func testExperimentFailsWhenAnySettingIsNotBoolean() {
        let validValue = "validValue"
        let invalidValue = "invalidValue"
        XCTAssertFalse(Experiment.configure(from: URL(string: "myapp://experiments/configure?\(validValue)=true&\(invalidValue)=7")))
        XCTAssertFalse(Experiment.named(validValue).exists)
        XCTAssertFalse(Experiment.named(invalidValue).exists)
    }

}
