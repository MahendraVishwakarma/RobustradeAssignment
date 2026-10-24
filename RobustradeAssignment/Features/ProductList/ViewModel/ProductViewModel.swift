//
//  ProductViewModel.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//
import Combine

@MainActor
final class ProductViewModel {
    
    private let clientNetwork: any AppNetworkRequest
    @Published var products = [ProductDetailsModel]()
    private(set) var state: ProductScreenState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    var onStateChange: ((ProductScreenState) -> Void)?
    private var isFetching = false
    private var nextPage = 1
    private var hasReachedEnd = false
    
    init(clientNetwork: any AppNetworkRequest) {
        self.clientNetwork = clientNetwork
    }

    func reloadProducts() {
        guard !isFetching else { return }
        products.removeAll()
        nextPage = 1
        hasReachedEnd = false
        fetchProducts()
    }
    
    func fetchProducts() {
        
        guard !isFetching, !hasReachedEnd else { return }

        isFetching = true
        state = .loading

        Task {
            defer { isFetching = false }
            
            do {
                let product: ProductStateModel = try await self.clientNetwork.request(
                    NetworkAPIParams(
                        subPath: .products,
                        currentIndex: self.nextPage
                    )
                )
                let receivedProducts = product.data ?? []
                if !receivedProducts.isEmpty {
                    nextPage = (product.pagination?.page ?? nextPage) + 1
                }
                hasReachedEnd = receivedProducts.isEmpty
                var existingIDs = Set(products.compactMap(\.id))
                let newProducts = receivedProducts.filter { product in
                    guard let id = product.id else { return true }
                    return existingIDs.insert(id).inserted
                }
                products.append(contentsOf: newProducts)
                if let total = product.pagination?.total {
                    hasReachedEnd = products.count >= total
                }
                state = self.products.isEmpty ? .empty : .loaded

            } catch let error as NetworkError {
                state = .error(error.localizedDescription)
            } catch is DecodingError {
                state = .error(
                    NetworkError.decodingError.localizedDescription
                )
                
            } catch {
                state = .error(
                    NetworkError.map(error).localizedDescription
                )
            }
        }
    }
}
