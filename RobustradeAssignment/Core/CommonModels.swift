//
//  CommonModels.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//

// it is default section for tableView
import Foundation

enum Section: Hashable {
    case main
}

enum ProductScreenState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}

enum NetworkError: LocalizedError {
    case noInternet
    case invalidResponse
    case serverError(Int)
    case decodingError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Please check your internet connection and try again."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .serverError(let statusCode):
            return "Something went wrong. Error code: \(statusCode)."
        case .decodingError:
            return "Unable to process the server response."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }

    static func map(_ error: Error) -> NetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost:
                return .noInternet
            default:
                return .unknown(error)
            }
        }

        return .unknown(error)
    }
}

extension Double {
    var displayPrice: String {
        formatted(.currency(code: "INR"))
    }
}

extension String {
    var imageUrl: URL? {
        URL(string: self)
    }
}

extension Int {
    var stringValue: String {
        "\(self)"
    }
}
