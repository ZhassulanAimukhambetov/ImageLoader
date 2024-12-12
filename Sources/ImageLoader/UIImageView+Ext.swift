//
//  UIImageView+Ext.swift
//  Real-Time-Stock-Tracker-App
//
//  Created by CodeReview on 12/12/24.
//
import UIKit

private enum ID {
    private static var value: Int = 0
    
    static func next() -> Int {
        value += 1
        return value
    }
}

public extension UIImageView {
    private static var xoAssociationKey: UInt8 = 0
    
    private var id: Int {
        get {
            return objc_getAssociatedObject(self, &Self.xoAssociationKey) as? Int ?? 0
        }
        
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &Self.xoAssociationKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
    }
    
    func setImage(url: String) {
        if let image = StockImageCache.object(for: url) {
            self.image = image
            
            return
        }
        
        let id = ID.next()
        self.id = id
        
        StockImageLoader.fetchImage(urlString: url) { [weak self] result in
            switch result {
            case .success(let image):
                StockImageCache.add(object: image, for: url)
                
                if self?.id == id {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            case .failure:
                break
            }
        }
    }
}