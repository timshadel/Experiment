//
//  ExperimentTests.swift
//  ExperimentTests
//
//  Created by Tim on 3/12/18.
//  Copyright © 2018 Day Logger, Inc. All rights reserved.
//

import XCTest
@testable import Experiment

class ExperimentTests: XCTestCase {

    // Use unique experiment names to keep tests isolated.

    func testEnableDisable() {
        var experiment = Experiment.named("enableDisable")
        XCTAssertFalse(experiment.enabled)
        experiment.enabled = true
        XCTAssertTrue(experiment.enabled)
        experiment.enabled = false
        XCTAssertFalse(experiment.enabled)
        experiment.remove()
    }
    
    func testURLConfig() {
        var experiment = Experiment.named("URLConfig")
        XCTAssertFalse(experiment.enabled)
        Experiment.configure(from: URL(string: "myapp://experiments/configure?URLConfig=true"))
        XCTAssertTrue(experiment.enabled)
        experiment.remove()
    }

}
