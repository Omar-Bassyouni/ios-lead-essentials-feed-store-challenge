//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: makeSUT())
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: makeSUT())
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: makeSUT())
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: makeSUT())
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		assertThatInsertDeliversNoErrorOnEmptyCache(on: makeSUT())
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		assertThatInsertDeliversNoErrorOnNonEmptyCache(on:  makeSUT())
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() {
		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: makeSUT())
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() {
		assertThatDeleteDeliversNoErrorOnEmptyCache(on: makeSUT())
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: makeSUT())
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() {
		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: makeSUT())
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		assertThatDeleteEmptiesPreviouslyInsertedCache(on: makeSUT())
	}
	
	func test_storeSideEffects_runSerially() {
		assertThatSideEffectsRunSerially(on: makeSUT())
	}
	
	// - MARK: Helpers
	private func makeSUT() -> FeedStore {
		return InMemoryFeedStore()
	}
}
