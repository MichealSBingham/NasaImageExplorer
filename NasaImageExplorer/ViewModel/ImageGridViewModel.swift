//
//  ImageGridViewModel.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//

import Foundation

@MainActor
class ImageGridViewModel: ObservableObject {
    @Published var images: [NasaImage] = []
    @Published var isLoading = false

    private let nasaAPIService = NasaAPIService()
    private var currentPage = 1
    private var currentQuery = ""

    func searchImages(query: String) async {
       
        isLoading = true
        currentQuery = query
        currentPage = 1
        
        self.images = []
        
        do {
            let images = try await nasaAPIService.fetchImages(query: query, page: currentPage)
           
            Task{ @MainActor in
                self.images = images
            }
            
           
            
        } catch {
            print("Error fetching images: \(error)")
        }
        isLoading = false
    }

    func loadMoreImages() async {
     
        guard !currentQuery.isEmpty else { return }
       
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        do {
            let moreImages = try await nasaAPIService.fetchImages(query: currentQuery, page: currentPage)
            self.images.append(contentsOf: moreImages)
        } catch {
            print("Error fetching more images: \(error)")
        }
        isLoading = false
    }
    
   
   
}

