//
//  InMemoryFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Omar Bassyouni on 24/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class InMemoryFeedStore: FeedStore {
	private var storedFeedModel: InMemoryFeedModel?
	
	public init() {}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		storedFeedModel = nil
		completion(nil)
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		storedFeedModel = InMemoryFeedModel(feed: feed, timestamp: timestamp)
		completion(nil)
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		guard let model = storedFeedModel else {
			return completion(.empty)
		}
		
		completion(.found(feed: model.feed, timestamp: model.timestamp))
	}
}

// MARK: - Domain Models
extension InMemoryFeedStore {
	private struct InMemoryFeedModel {
		let feed:  [LocalFeedImage]
		let timestamp: Date
	}
}
