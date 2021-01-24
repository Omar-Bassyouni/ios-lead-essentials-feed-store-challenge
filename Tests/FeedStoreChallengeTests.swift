//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

final class UserDefaultsFeedStore: FeedStore {
	private struct Cache: Codable {
		let feed: [UserDefaultsFeedModel]
		let timestamp: Date
		
		var localFeed: [LocalFeedImage] {
			feed.map { $0.toLocal() }
		}
	}
	
	private struct UserDefaultsFeedModel: Codable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		init(_ model: LocalFeedImage) {
			id = model.id
			description = model.description
			location = model.location
			url = model.url
		}
		
		func toLocal() -> LocalFeedImage {
			LocalFeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		completion(nil)
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let cache = Cache(feed: feed.map(UserDefaultsFeedModel.init), timestamp: timestamp)
		let encoder = PropertyListEncoder()
		let propertyListData = try! encoder.encode(cache)
		UserDefaults.standard.setValue(propertyListData, forKey: "some key")
		completion(nil)
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		guard let data = UserDefaults.standard.data(forKey: "some key") else {
			return completion(.empty)
		}
		
		let decoder = PropertyListDecoder()
		let cache = try! decoder.decode(Cache.self, from: data)
		completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
	}
}

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	override func setUp() {
		super.setUp()
		setupEmptyFeedStoreState()
	}
	
	override func tearDown() {
		undoStoreSideEffects()
		super.tearDown()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()
		
		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
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
		UserDefaultsFeedStore()
	}
	
	private func setupEmptyFeedStoreState() {
		removeAllDataInUserDefaults()
	}
	
	private func undoStoreSideEffects() {
		removeAllDataInUserDefaults()
	}
	
	private func removeAllDataInUserDefaults() {
		let domain = Bundle.main.bundleIdentifier!
		UserDefaults.standard.removePersistentDomain(forName: domain)
		UserDefaults.standard.synchronize()
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
