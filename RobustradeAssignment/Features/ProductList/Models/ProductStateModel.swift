//
//  ProductDataModel.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//

import Foundation

// MARK: - ProductStateModel
struct ProductStateModel: Codable {
    let data: [ProductDetailsModel]?
    let pagination: Pagination?
}

// MARK: - Datum
struct ProductDetailsModel: Codable, Hashable {
    let id: Int?
    let title: String?
    let price: Double?
    let description, category, brand: String?
    let stock: Int?
    let image: String?
    let specs: Specs?
    let rating: ProductRating?

    var resolvedImageURL: URL? {
        guard let imageURL = image?.imageUrl else { return nil }

        // fakeapi image giving 404, so used picsum photo to show the running code
        guard imageURL.host == "fakeapi.net",
              imageURL.path.hasPrefix("/images/"),
              let id else {
            return imageURL
        }

        return URL(string: "https://picsum.photos/seed/robustrade-product-\(id)/240/240")
    }
}

// MARK: - Rating
struct ProductRating: Codable, Hashable {
    let rate: Double?
    let count: Int?
}

// MARK: - Specs
struct Specs: Codable, Hashable {
    let color, weight, storage, battery: String?
    let waterproof: Bool?
    let screen, ram, connection, capacity: String?
    let output: String?
}

// MARK: - Pagination
struct Pagination: Codable {
    let page, limit, total: Int?
}
