//
//  AppNetworkRequest.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//

import Foundation


protocol AppNetworkRequest {
    func request<T: Decodable>(_ apiParams: NetworkAPIParams) async throws -> T
}
