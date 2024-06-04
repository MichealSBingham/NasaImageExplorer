//
//  ImageGridCell.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//

import UIKit

class ImageGridCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageGridCell"

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(with url: URL) {
            Task {
                if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
                    self.imageView.image = cachedImage
                } else {
                    if let data = try? await fetchData(from: url) {
                        if let image = UIImage(data: data) {
                            ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
                            await MainActor.run {
                                self.imageView.alpha = 0 // Start with transparent
                                self.imageView.image = image
                                UIView.animate(withDuration: 0.5) { // Animate fade-in
                                    self.imageView.alpha = 1
                                }
                            }
                        }
                    }
                }
            }
        }

    private func fetchData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
