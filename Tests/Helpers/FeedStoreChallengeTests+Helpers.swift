//
//  FeedStoreChallengeTests+Helpers.swift
//  Tests
//
//  Created by Omar Bassyouni on 24/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
	func testUserDefaults() -> UserDefaults {
		return UserDefaults(suiteName: testUserDefaultsSuiteName())!
	}

	func testUserDefaultsSuiteName() -> String {
		return "\(type(of: self))UserDefaultsSuiteName"
	}

	func removeAllDataInUserDefaults() {
		UserDefaults.standard.removePersistentDomain(forName: testUserDefaultsSuiteName())
	}
}
