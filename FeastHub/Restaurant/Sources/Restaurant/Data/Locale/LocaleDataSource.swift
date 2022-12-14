//
//  LocaleDataSource.swift
//  FeastHub
//
//  Created by Kevin Jonathan on 10/12/22.
//

import Foundation
import RealmSwift
import Combine
import CorePackage

public protocol LocaleDataSourceProtocol: AnyObject {
    func getFavoriteRestaurants() -> AnyPublisher<[RestaurantEntity], Error>
    func getRestaurantIsFavorite(withId id: String) -> AnyPublisher<Bool, Error>
    func addFavoriteRestaurant(from restaurant: RestaurantEntity) -> AnyPublisher<Bool, Error>
    func deleteFavoriteRestaurant(withId id: String) -> AnyPublisher<Bool, Error>
}

public class LocaleDataSource: NSObject {
    private let realm: Realm?
    
    private init(realm: Realm?) {
        self.realm = realm
    }
    
    public static let sharedInstance: (Realm?) -> LocaleDataSource = { realmDatabase in
        return LocaleDataSource(realm: realmDatabase)
    }
}

extension LocaleDataSource: LocaleDataSourceProtocol {
    public func getFavoriteRestaurants() -> AnyPublisher<[RestaurantEntity], Error> {
        return Future<[RestaurantEntity], Error> { completion in
            if let realm = self.realm {
                let restaurantEntities = {
                    realm.objects(RestaurantEntity.self)
                        .sorted(byKeyPath: "name", ascending: true)
                }()
                completion(.success(restaurantEntities.toArray(ofType: RestaurantEntity.self)))
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
    
    public func getRestaurantIsFavorite(
        withId id: String
    ) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { completion in
            if let realm = self.realm {
                let restaurants = realm.objects(RestaurantEntity.self).filter("id = %@", id)
                
                if !restaurants.isEmpty {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
    
    public func addFavoriteRestaurant(
        from restaurant: RestaurantEntity
    ) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { completion in
            if let realm = self.realm {
                do {
                    try realm.write {
                        realm.add(restaurant, update: .all)
                        completion(.success(true))
                    }
                } catch {
                    completion(.failure(DatabaseError.requestFailed))
                }
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
    
    public func deleteFavoriteRestaurant(
        withId id: String
    ) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { completion in
            if let realm = self.realm {
                do {
                    let restaurants = realm.objects(RestaurantEntity.self).filter("id = %@", id)
                    try realm.write {
                        for restaurant in restaurants {
                            realm.delete(restaurant)
                        }
                        completion(.success(true))
                    }
                } catch {
                    completion(.failure(DatabaseError.requestFailed))
                }
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
}
