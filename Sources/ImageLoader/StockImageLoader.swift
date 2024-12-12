//
//  StockImageLoader.swift
//  Real-Time-Stock-Tracker-App
//
//  Created by D on 04.10.2024.
//

import UIKit

struct StockImageCache {
    private static let imageCache = NSCache<NSString, UIImage>()
    
    static func add(object: UIImage, for key: String) {
        imageCache.setObject(object, forKey: key as NSString)
    }

    static func object(for key: String) -> UIImage? {
        imageCache.object(forKey: key as NSString)
    }
}

struct StockImageLoader {
    static func fetchImage(
        urlString: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageLoadError.invalidURL(urlString)))
            
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(ImageLoadError.invalidResponse(response)))
                
                return
            }
            
            if let data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(ImageLoadError.invalidImageData))
            }
        }.resume()
    }
}
