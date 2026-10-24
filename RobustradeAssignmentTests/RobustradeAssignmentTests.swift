//
//  ProductViewModel.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//

import XCTest
@testable import RobustradeAssignment

final class RobustradeAssignmentTests: XCTestCase {
    func testClientEndpointBuildsExpectedURL() {
        let url = ClientEndpoint().url(for: .products, page: 2)

        XCTAssertEqual(url.absoluteString, "https://fakeapi.net/products?page=2&limit=10")
    }

    func testPriceUsesIndianCurrencyFormatting() {
        XCTAssertTrue(1000.5.displayPrice.contains("₹"))
    }

    @MainActor
    func testFetchProductsLoadsInitialPage() async {
        let client = MockNetworkClient(results: [.success(response(page: 1, products: [product(id: 1)]))])
        let viewModel = ProductViewModel(clientNetwork: client)

        viewModel.fetchProducts()
        await waitUntil { viewModel.state == .loaded }

        XCTAssertEqual(viewModel.products.map(\.id), [1])
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(client.requestedPages, [1])
    }

    @MainActor
    func testFetchProductsAppendsNextPageWithoutDuplicates() async {
        let client = MockNetworkClient(results: [
            .success(response(page: 1, products: [product(id: 1), product(id: 2)])),
            .success(response(page: 2, products: [product(id: 2), product(id: 3)]))
        ])
        let viewModel = ProductViewModel(clientNetwork: client)

        viewModel.fetchProducts()
        await waitUntil { viewModel.state == .loaded }
        viewModel.fetchProducts()
        await waitUntil { client.requestedPages.count == 2 && viewModel.state == .loaded }

        XCTAssertEqual(viewModel.products.compactMap(\.id), [1, 2, 3])
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(client.requestedPages, [1, 2])
    }

    @MainActor
    func testEmptyResponseSetsEmptyStateAndStopsFurtherPaging() async {
        let client = MockNetworkClient(results: [.success(response(page: 1, products: []))])
        let viewModel = ProductViewModel(clientNetwork: client)

        viewModel.fetchProducts()
        await waitUntil { viewModel.state == .empty }
        viewModel.fetchProducts()
        await Task.yield()

        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertTrue(viewModel.products.isEmpty)
        XCTAssertEqual(client.requestedPages, [1])
    }

    @MainActor
    func testFailureSetsErrorState() async {
        let client = MockNetworkClient(results: [.failure(URLError(.notConnectedToInternet))])
        let viewModel = ProductViewModel(clientNetwork: client)

        viewModel.fetchProducts()
        await waitUntil {
            viewModel.state == .error("Please check your internet connection and try again.")
        }

        XCTAssertEqual(viewModel.state, .error("Please check your internet connection and try again."))
    }

    @MainActor
    private func waitUntil(
        _ condition: @escaping @MainActor () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<1_000 {
            if condition() { return }
            await Task.yield()
        }
        XCTFail("Timed out waiting for the expected state.", file: file, line: line)
    }

    private func response(page: Int, products: [ProductDetailsModel]) -> ProductStateModel {
        ProductStateModel(data: products, pagination: Pagination(page: page, limit: 10, total: nil))
    }

    private func product(id: Int) -> ProductDetailsModel {
        ProductDetailsModel(id: id, title: "Product \(id)", price: 10, description: nil, category: nil, brand: nil, stock: nil, image: nil, specs: nil, rating: nil)
    }
}

private final class MockNetworkClient: AppNetworkRequest {
    private var results: [Result<ProductStateModel, Error>]
    private(set) var requestedPages: [Int] = []

    init(results: [Result<ProductStateModel, Error>]) {
        self.results = results
    }

    func request<T: Decodable>(_ apiParams: NetworkAPIParams) async throws -> T {
        requestedPages.append(apiParams.currentIndex)
        guard !results.isEmpty else { throw URLError(.badServerResponse) }

        switch results.removeFirst() {
        case .success(let response):
            guard let typedResponse = response as? T else { throw NetworkError.invalidResponse }
            return typedResponse
        case .failure(let error):
            throw error
        }
    }
}
