//
//  RemoteDataSource.swift
//  FeastHub
//
//  Created by Kevin Jonathan on 10/12/22.
//

import Foundation
import Alamofire
import Combine
import CorePackage

public protocol RemoteDataSourceProtocol: AnyObject {
    func getList() -> AnyPublisher<[RestaurantResponse], Error>
    func getDetail(by id: String) -> AnyPublisher<RestaurantResponse, Error>
    func searchList(by query: String) -> AnyPublisher<[RestaurantResponse], Error>
    func postReview(by id: String, name: String, review: String) -> AnyPublisher<[ReviewResponse], Error>
}

public class RemoteDataSource: NSObject {
    private override init() { }
    public static let sharedInstance: RemoteDataSource =  RemoteDataSource()
}

extension RemoteDataSource: RemoteDataSourceProtocol {
    public func getList() -> AnyPublisher<[RestaurantResponse], Error> {
        return Future<[RestaurantResponse], Error> { completion in
            if let url = URL(string: Endpoints.Restaurant.list.url) {
                AF.request(url)
                    .validate()
                    .responseDecodable(of: RestaurantListResponse.self) { response in
                        switch response.result {
                        case .success(let value):
                            completion(.success(value.restaurants ?? []))
                        case .failure:
                            completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getDetail(
        by id: String
    ) -> AnyPublisher<RestaurantResponse, Error> {
        return Future<RestaurantResponse, Error> { completion in
            if let url = URL(string: Endpoints.Restaurant.detail.url + id) {
                AF.request(url)
                    .validate()
                    .responseDecodable(of: RestaurantDetailResponse.self) { response in
                        switch response.result {
                        case .success(let value):
                            if let restaurant = value.restaurant {
                                completion(.success(restaurant))
                            } else {
                                completion(.failure(URLError.invalidResponse))
                            }
                        case .failure:
                            completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    public func searchList(
        by query: String
    ) -> AnyPublisher<[RestaurantResponse], Error> {
        return Future<[RestaurantResponse], Error> { completion in
            if let url = URL(string: Endpoints.Restaurant.search.url + (query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")) {
                AF.request(url)
                    .validate()
                    .responseDecodable(of: RestaurantSearchResponse.self) { response in
                        switch response.result {
                        case .success(let value):
                            completion(.success(value.restaurants ?? []))
                        case .failure:
                            completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    public func postReview(
        by id: String,
        name: String,
        review: String
    ) -> AnyPublisher<[ReviewResponse], Error> {
        return Future<[ReviewResponse], Error> { completion in
            if let url = URL(string: Endpoints.Restaurant.addReview.url) {
                let params: [String: String] = [
                    "id": id,
                    "name": name,
                    "review": review
                ]
                
                AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
                    .validate()
                    .responseDecodable(of: AddNewReviewResponse.self) { response in
                        switch response.result {
                        case .success(let value):
                            completion(.success(value.customerReviews ?? []))
                        case .failure:
                            completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
}
