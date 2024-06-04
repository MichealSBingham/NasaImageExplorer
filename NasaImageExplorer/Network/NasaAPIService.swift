//
//  NasaAPIService.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//

import Foundation


class NasaAPIService {
    private let baseURL = "https://images-api.nasa.gov/search"

    func fetchImages(query: String, page: Int) async throws -> [NasaImage] {
       // print("fetching images from query: \(query) and page \(page)")
        guard var urlComponents = URLComponents(string: baseURL) else { throw URLError(.badURL) }
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "media_type", value: "image"),
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = urlComponents.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode(NasaImageResponse.self, from: data)
        return response.collection.items.compactMap { item in
            guard let data = item.data.first, let link = item.links.first else { return nil }
            return NasaImage(
                title: data.title,
                description: data.description,
                photographer: data.photographer,
                location: data.location,
                thumbnailURL: URL(string: link.href) ?? URL(string: "")!,
                imageURL: URL(string: link.href) ?? URL(string: "")!
            )
        }
    }
}
