//
//  StockImageLoader.swift
//  Real-Time-Stock-Tracker-App
//
//  Created by D on 04.10.2024.
//

import UIKit
import SwiftUI

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
    private typealias Completion = (Result<UIImage, Error>) -> Void
    
    @ThreadSafe
    private static var completions: [String: [Completion]] = [:]
    private static var count = 0
    
    static func fetchImage(
        urlString: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        if let image = StockImageCache.object(for: urlString) {
            completion(.success(image))
            
            return
        }
        
        if completions[urlString] != nil {
            completions[urlString]?.append(completion)
            
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageLoadError.invalidURL(urlString)))
            
            return
        }
        count += 1
        print("\(count) - \(urlString)")
        completions[urlString] = [completion]
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completions[urlString]?.forEach { $0(.failure(ImageLoadError.invalidResponse(response))) }
                completions.removeValue(forKey: urlString)
                
                return
            }
            
            if let data, let image = UIImage(data: data) {
                StockImageCache.add(object: image, for: urlString)
                completions[urlString]?.forEach { $0(.success(image)) }
                completions.removeValue(forKey: urlString)
            } else {
                completions[urlString]?.forEach { $0(.failure(ImageLoadError.invalidImageData)) }
                completions.removeValue(forKey: urlString)
            }
        }.resume()
    }
}


@propertyWrapper
struct ThreadSafe<Value> {
    private let lock = NSLock()
    
    private var _value: Value
    
    var wrappedValue: Value {
        get {
            lock.lock()
            
            defer { lock.unlock() }
            
            return _value
        }
        
        set {
            lock.lock()
            _value = newValue
            lock.unlock()
        }
    }
    
    
    init(wrappedValue: Value) {
        self._value = wrappedValue
    }
}
