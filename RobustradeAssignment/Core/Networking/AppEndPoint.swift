//
//  Untitled.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//
import Foundation

protocol AppEndPoint {
    var baseURL: URL { get }
}

struct ClientEndpoint: AppEndPoint {
    let baseURL = URL(string: "https://fakeapi.net")!

    func url(for api: Apis, page: Int) -> URL {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(api.rawValue),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: "10")
        ]
        return components.url!
    }
}
