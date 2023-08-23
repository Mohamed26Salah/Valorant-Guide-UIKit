//
//  Valorant_Guide_UIKitTests.swift
//  Valorant-Guide-UIKitTests
//
//  Created by Mohamed Salah on 16/08/2023.
//

import XCTest
@testable import Valorant_Guide_UIKit
final class Valorant_Guide_UIKitTests: XCTestCase {
    var apiClient: APIClient!
    private let provider = NetworkAPIProvider()
    let baseURL = URL(string: K.Links.apiLink)
    
    override func setUpWithError() throws {
        guard let bundle = Bundle.unitTest.path(forResource: "stub", ofType: "json") else {
            XCTFail("3ZOOZ out")
            return
        }
        apiClient = APIClient(baseURL: URL(fileURLWithPath: bundle), apiProvider: provider)
    }

    override func tearDownWithError() throws {
        apiClient = nil
    }

    func testApiFetchSuccessful() {
        let promise = XCTestExpectation(description: "3zooz")
        var responseError: Error?
        var agents: AgentsParser?
        let baseURL = URL(string: K.Links.apiLink)
//        guard let bundle = Bundle.unitTest.path(forResource: "stub", ofType: "json") else {
//            XCTFail("3ZOOZ out")
//            return
//        }
        apiClient.fetchResourceData(modelDTO: agents, resource: "", completion: { result in
            switch result {
            case .success(let data):
                agents = data
            case .failure(let error):
                responseError = error
            }
            promise.fulfill()
        })
        wait(for: [promise], timeout: 1)
        XCTAssertNil(responseError)
        XCTAssertNotNil(agents)
        
    }

}
