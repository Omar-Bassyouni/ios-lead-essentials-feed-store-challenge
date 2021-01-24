//
//  UserDefaultsFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Omar Bassyouni on 24/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class UserDefaultsFeedStore {
	
	private let userDefaults: UserDefaults
	private let queue = DispatchQueue(label: "\(UserDefaultsFeedStore.self)Queue",
									  qos: .userInitiated,
									  attributes: .concurrent)
	
	private var feedCacheKey: String {
		"feed_cache_key"
	}
	
	public init(_ userDefaults: UserDefaults = UserDefaults.standard) {
		self.userDefaults = userDefaults
	}
}

// MARK: - FeedStore
extension UserDefaultsFeedStore: FeedStore {
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let feedCacheKey = self.feedCacheKey
		
		queue.async(flags: .barrier) { [weak self] in
			self?.userDefaults.set(nil, forKey: feedCacheKey)
			completion(nil)
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let feedCacheKey = self.feedCacheKey
		
		queue.async(flags: .barrier) { [weak self] in
			let cache = Cache(feed: feed.map(UserDefaultsFeedModel.init), timestamp: timestamp)
			
			let encoder = PropertyListEncoder()
			// Note: I don't know to test this in tests, how test drive it to put in a
			// do catch block
			let propertyListData = try! encoder.encode(cache)
			
			self?.userDefaults.setValue(propertyListData, forKey: feedCacheKey)
			
			completion(nil)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		queue.async { [weak self] in
			do {
				try self?.retrieveFeed(completion: completion)
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	private func retrieveFeed(completion: @escaping RetrievalCompletion) throws {
		guard let data = userDefaults.data(forKey: feedCacheKey) else {
			return completion(.empty)
		}
		
		let decoder = PropertyListDecoder()
		let cache = try decoder.decode(Cache.self, from: data)
		
		completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
	}
}

// MARK: - Domain Models
extension UserDefaultsFeedStore {
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
}
