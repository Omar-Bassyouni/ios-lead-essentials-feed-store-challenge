//
//  FeedStoreChallengeTests+Helpers.swift
//  Tests
//
//  Created by Omar Bassyouni on 24/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

func testUserDefaults() -> UserDefaults {
	return UserDefaults(suiteName: testUserDefaultsSuiteName())!
}

func testUserDefaultsSuiteName() -> String {
	return "TestsUserDefaultsSuiteName"
}

func removeAllDataInUserDefaults() {
	UserDefaults.standard.removePersistentDomain(forName: testUserDefaultsSuiteName())
	UserDefaults.standard.synchronize()
}
