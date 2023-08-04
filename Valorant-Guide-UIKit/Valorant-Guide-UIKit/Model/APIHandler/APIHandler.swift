//
//  APIHandler.swift
//  Valorant-Guide-UIKit
//
//  Created by Mohamed Salah on 04/08/2023.
//

import Foundation

enum URLHeads: String {
    case agents
    case bundles
    case maps
    case seasons
    case weapons
}

protocol APIProvider {
    func fetchData(for resource: String, completion: @escaping (Result<Data, Error>) -> ())
}

class NetworkAPIProvider: APIProvider {
    func fetchData(for resource: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let apiURL = URL(string: resource) else {
            let customError = NSError(domain: "URL is Wrong", code: 0, userInfo: nil)
            completion(.failure(customError))
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: apiURL) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let customError = NSError(domain: "NoDataError", code: 0, userInfo: nil)
                completion(.failure(customError))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}

class APIClient {
    private let baseURL: URL
    private let apiProvider: APIProvider
    
    init(baseURL: URL, apiProvider: APIProvider) {
        self.baseURL = baseURL
        self.apiProvider = apiProvider
    }
    func fetchResourceData<model: Decodable>(modelDTO: model, resource: String, completion: @escaping (Result<model, Error>) -> Void){
        let resourceURL = baseURL.appendingPathComponent(resource)
        apiProvider.fetchData(for: resourceURL.absoluteString) { result in
            switch result {
            case .success(let data):
                do {
                    let parsedData = try JSONDecoder().decode(model.self, from: data)
                    completion(.success(parsedData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }// RX swift(MVVM) /
    
    
}
