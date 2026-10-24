//
//  ClientNetworkRequest.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//

import Foundation

struct NetworkAPIParams {
    let subPath: Apis
    let currentIndex: Int
}

final class NetworkClient: AppNetworkRequest {
    private let endpoint: ClientEndpoint
    
    init(endpoint: ClientEndpoint) {
        self.endpoint = endpoint
    }
    
    func request<T: Decodable>(_ apiParams: NetworkAPIParams) async throws -> T {
        
        let url = endpoint.url(for: apiParams.subPath, page: apiParams.currentIndex)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.serverError(response.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
