//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

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
	
	func test_insert_runsSerially() {
		let sut = makeSUT()
		
		assertThatInsertSideEffectsRunSerially(on: sut)
	}
}

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
	func test_retrieve_deliversFailureOnRetrievalError() {
		let userDefaults = testUserDefaults()
		let sut = makeSUT(userDefaults: userDefaults)

		insert((uniqueImageFeed(), Date()), to: sut)
		
		injectInValidData(to: userDefaults)

		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnFailure() {
		let userDefaults = testUserDefaults()
		let sut = makeSUT(userDefaults: userDefaults)

		insert((uniqueImageFeed(), Date()), to: sut)
		
		injectInValidData(to: userDefaults)
		
		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
	}
}

// MARK: - Helpers
extension FeedStoreChallengeTests {
	private func makeSUT(userDefaults: UserDefaults? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
		let sut = UserDefaultsFeedStore(userDefaults ?? testUserDefaults())
		trackForMemoryLeak(for: sut, file: file, line: line)
		return sut
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
	
	private func assertThatInsertSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		var completedOperationsInOrder = [XCTestExpectation]()

		let exp1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed(), timestamp: Date()) { _ in
			completedOperationsInOrder.append(exp1)
			
			self.fulfill(exp1, afterMilliseconds: 80)
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
	
	private func injectInValidData(to userDefaults: UserDefaults) {
		let allKeys = userDefaults.dictionaryRepresentation().keys
		for key in allKeys {
			userDefaults.setValue(Data("invalid Data".utf8), forKey: key)
		}
	}
}
