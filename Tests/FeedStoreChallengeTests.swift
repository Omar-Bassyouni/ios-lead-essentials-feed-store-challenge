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
	
	private let queue = DispatchQueue(label: "\(UserDefaultsFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
	private let userDefaults: UserDefaults
	
	public init(_ userDefaults: UserDefaults = UserDefaults.standard) {
		self.userDefaults = userDefaults
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async(flags: .barrier) { [weak self] in
			self?.userDefaults.set(nil, forKey: "some key")
			completion(nil)
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		queue.async(flags: .barrier) { [weak self] in
			let cache = Cache(feed: feed.map(UserDefaultsFeedModel.init), timestamp: timestamp)
			let encoder = PropertyListEncoder()
			let propertyListData = try! encoder.encode(cache)
			self?.userDefaults.setValue(propertyListData, forKey: "some key")
			completion(nil)
		}
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		queue.async { [weak self] in
			guard let data = self?.userDefaults.data(forKey: "some key") else {
				return completion(.empty)
			}
			
			let decoder = PropertyListDecoder()
			let cache = try! decoder.decode(Cache.self, from: data)
			completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
		}
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
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()
		
		assertThatSideEffectsRunSerially(on: sut)
	}
	
	func test_delete_runsSerially() {
		let sut = makeSUT()
		
		assertThatDeleteSideEffectsRunSerially(on: sut)
	}
	
	func test_insert_runsSerially() {
		let sut = makeSUT()
		
		assertThatInsertSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT(userDefaults: UserDefaults? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
		let sut = UserDefaultsFeedStore(userDefaults ?? testUserDefaults())
		trackForMemoryLeak(for: sut, file: file, line: line)
		return sut
	}
	
	private func testUserDefaults() -> UserDefaults {
		return UserDefaults(suiteName: testUserDefaultsSuiteName())!
	}
	
	private func testUserDefaultsSuiteName() -> String {
		return "\(type(of: self))UserDefaultsSuiteName"
	}
	
	private func trackForMemoryLeak(for object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak object] in
			XCTAssertNil(object, "Potential memory leak for \(String(describing: object))", file: file, line: line)
		}
	}
	
	private func setupEmptyFeedStoreState() {
		removeAllDataInUserDefaults()
	}
	
	private func undoStoreSideEffects() {
		removeAllDataInUserDefaults()
	}
	
	private func removeAllDataInUserDefaults() {
		UserDefaults.standard.removePersistentDomain(forName: testUserDefaultsSuiteName())
		UserDefaults.standard.synchronize()
	}
	
	private func assertThatDeleteSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		var completedOperationsInOrder = [XCTestExpectation]()

		let exp1 = expectation(description: "Operation 1")
		sut.deleteCachedFeed { _ in
			completedOperationsInOrder.append(exp1)
			
			self.fulfill(exp1, afterMilliseconds: 100)
		}

		let exp2 = expectation(description: "Operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationsInOrder.append(exp2)
			exp2.fulfill()
		}

		let exp3 = expectation(description: "Operation 3")
		sut.deleteCachedFeed { _ in
			completedOperationsInOrder.append(exp3)
			exp3.fulfill()
		}

		waitForExpectations(timeout: 0.1)

		XCTAssertEqual(completedOperationsInOrder, [exp1, exp2, exp3], "Expected delete side-effects to run serially but operations finished in the wrong order", file: file, line: line)
	}
	
	private func assertThatInsertSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		var completedOperationsInOrder = [XCTestExpectation]()

		let exp1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed(), timestamp: Date()) { _ in
			completedOperationsInOrder.append(exp1)
			
			self.fulfill(exp1, afterMilliseconds: 100)
		}

		let exp2 = expectation(description: "Operation 2")
		sut.insert(uniqueImageFeed(), timestamp: Date()) { _ in
			completedOperationsInOrder.append(exp2)
			exp2.fulfill()
		}

		let exp3 = expectation(description: "Operation 3")
		sut.insert(uniqueImageFeed(), timestamp: Date()) { _ in
			completedOperationsInOrder.append(exp3)
			exp3.fulfill()
		}

		waitForExpectations(timeout: 0.1)

		XCTAssertEqual(completedOperationsInOrder, [exp1, exp2, exp3], "Expected delete side-effects to run serially but operations finished in the wrong order", file: file, line: line)
	}
	
	private func fulfill(_ exp: XCTestExpectation, afterMilliseconds milliseconds: Int) {
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
			exp.fulfill()
		}
	}
}

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
