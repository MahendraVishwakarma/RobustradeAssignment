//
//  ImageLoader.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//



import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func loadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    ) {
        // 1. Check memory cache
        if let cachedImage = cache.object(forKey: url as NSURL) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }

        // 2. Download asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                error == nil,
                let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode),
                let data,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            // 3. Save image in cache
            self?.cache.setObject(image, forKey: url as NSURL)

            // 4. Update UI on the main thread
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
