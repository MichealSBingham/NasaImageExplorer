//
//  NasaImageResponse.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//

import Foundation

struct NasaImageResponse: Codable {
    let collection: NasaImageCollection

    struct NasaImageCollection: Codable {
        let items: [NasaImageItem]

        struct NasaImageItem: Codable {
            let data: [NasaImageData]
            let links: [NasaImageLink]

            struct NasaImageData: Codable {
                let title: String
                let description: String?
                let photographer: String?
                let location: String?
            }

            struct NasaImageLink: Codable {
                let href: String
            }
        }
    }
}
