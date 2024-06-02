//
//  ImageDetailViewModel.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//

import Foundation

@MainActor
class ImageDetailViewModel: ObservableObject {
    @Published var image: NasaImage

    init(image: NasaImage) {
        self.image = image
    }
}
