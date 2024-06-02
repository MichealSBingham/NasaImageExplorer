//
//  NasaImage.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//


import Foundation

struct NasaImage: Codable, Hashable {
    let title: String
    let description: String?
    let photographer: String?
    let location: String?
    let thumbnailURL: URL
    let imageURL: URL

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case photographer
        case location
    }
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(thumbnailURL)
        hasher.combine(imageURL)
    }

    // Conformance to Equatable (Hashable requires this)
    static func == (lhs: NasaImage, rhs: NasaImage) -> Bool {
        return lhs.title == rhs.title &&
               lhs.thumbnailURL == rhs.thumbnailURL &&
               lhs.imageURL == rhs.imageURL
    }
}

extension NasaImage {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        photographer = try container.decodeIfPresent(String.self, forKey: .photographer)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        
        let linksContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        let links = try linksContainer.decode([Link].self, forKey: DynamicCodingKeys(stringValue: "links")!)
        
        guard let thumbnailLink = links.first(where: { $0.rel == "preview" }),
              let imageLink = links.first(where: { $0.rel == "original" }) else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.title, in: container, debugDescription: "Links missing")
        }
        
        thumbnailURL = URL(string: thumbnailLink.href)!
        imageURL = URL(string: imageLink.href)!
    }
    
    private struct Link: Codable {
        let href: String
        let rel: String
    }
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
}
