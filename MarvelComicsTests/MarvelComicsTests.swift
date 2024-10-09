//
//  MarvelComicsTests.swift
//  MarvelComicsTests
//
//  Created by Gil casimiro on 07/10/24.
//

import XCTest
import Combine
@testable import MarvelComics

class MarvelServiceTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    var marvelService: MarvelService!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        
        // Configure URLSession with the MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        marvelService = MarvelService(session: session)
    }
    
    override func tearDown() {
        cancellables = nil
        marvelService = nil
        super.tearDown()
    }
    
    func testFetchComicsSuccess() {
        let expectedComics = [Comic(id: 12345, title: "Mock Comic", description: "A mock comic", thumbnail: Comic.Thumbnail(path: "https://example.com/image", extension: "jpg"), variants: nil, creators: nil)]
        
        let mockResponse = MarvelResponse(data: ComicDataWrapper(results: expectedComics))
        let mockData = try! JSONEncoder().encode(mockResponse)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        let expectation = self.expectation(description: "Fetch comics should succeed")
        
        marvelService.fetchComics(offset: 0, limit: 20)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, got error \(error) instead")
                }
            }, receiveValue: { comics in
                XCTAssertEqual(comics, expectedComics)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchComicsFailure() {
        // Simulate an error
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let expectation = self.expectation(description: "Fetch comics should fail")
        
        marvelService.fetchComics(offset: 0, limit: 20)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, got success instead")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
