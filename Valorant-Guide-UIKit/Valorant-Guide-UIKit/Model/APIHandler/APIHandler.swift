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

enum Urls {
    case agents
    case bundles
    case maps
    case weapons
    case seasons
    
    var basePath: String {
        return "https://valorant-api.com/v1"
    }
    
    var urlString: String {
        switch self {
        case .agents:
            return "\(basePath)/agents"
        case .bundles:
            return "\(basePath)/bundles"
        case .maps:
            return "\(basePath)/maps"
        case .weapons:
            return "\(basePath)/weapons"
        case .seasons:
            return "\(basePath)/seasons"
        }
    }
}

//let agentsUrlString = Urls.agents.urlString



class APIClient {
    private let baseURL: URL //No
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
    }
    func fetchResourceData<model: Decodable>(modelDTO: model, url: String, completion: @escaping (Result<model, Error>) -> Void){
        apiProvider.fetchData(for: url) { result in
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
    }
    
}
