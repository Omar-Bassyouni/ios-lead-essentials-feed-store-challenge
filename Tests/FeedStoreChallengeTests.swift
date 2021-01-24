//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class InMemoryFeedStore: FeedStore {
	private struct InMemoryFeedModel {
		let feed:  [LocalFeedImage]
		let timestamp: Date
	}
	
	private var storedFeedModel: InMemoryFeedModel?
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		completion(nil)
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		storedFeedModel = InMemoryFeedModel(feed: feed, timestamp: timestamp)
		completion(nil)
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		guard let model = storedFeedModel else {
			return completion(.empty)
		}
		
		completion(.found(feed: model.feed, timestamp: model.timestamp))
	}
}

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	//  ***********************
	//
	//  Follow the TDD process:
	//
	//  1. Uncomment and run one test at a time (run tests with CMD+U).
	//  2. Do the minimum to make the test pass and commit.
	//  3. Refactor if needed and commit again.
	//
	//  Repeat this process until all tests are passing.
	//
	//  ***********************
	
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
		//		let sut = makeSUT()
		//
		//		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() {
		//		let sut = makeSUT()
		//
		//		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		//		let sut = makeSUT()
		//
		//		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() {
		//		let sut = makeSUT()
		//
		//		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() -> FeedStore {
		return InMemoryFeedStore()
	}
	
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() {
////		let sut = makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() {
////		let sut = makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
