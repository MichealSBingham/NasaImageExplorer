//
//  ImageCache.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/3/24.
//

import Foundation
import UIKit


class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, CacheEntry>()
    private let expirationInterval: TimeInterval = 60 * 60 * 24 // 24 hour cache 

    private init() {}

    func object(forKey key: NSString) -> UIImage? {
        guard let entry = cache.object(forKey: key), !entry.isExpired else {
            cache.removeObject(forKey: key)
            return nil
        }
        return entry.image
    }

    func setObject(_ obj: UIImage, forKey key: NSString) {
        let entry = CacheEntry(image: obj, expirationDate: Date().addingTimeInterval(expirationInterval))
        cache.setObject(entry, forKey: key)
    }

    private class CacheEntry {
        let image: UIImage
        let expirationDate: Date

        init(image: UIImage, expirationDate: Date) {
            self.image = image
            self.expirationDate = expirationDate
        }

        var isExpired: Bool {
            return Date() > expirationDate
        }
    }
}
