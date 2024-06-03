//
//  WelcomeView.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/3/24.
//

import Foundation
import UIKit



class WelcomeView: UIView {
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "NASA Image Explorer"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nasaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let welcomeTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Explore the universe through NASA's vast image library."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        loadImage(from: URL(string: "https://cdn.mos.cms.futurecdn.net/baYs9AuHxx9QXeYBiMvSLU-1200-80.jpg.webp")!) // Replace with the actual URL
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(welcomeLabel)
        addSubview(nasaImageView)
        addSubview(welcomeTextLabel)

        NSLayoutConstraint.activate([
            nasaImageView.topAnchor.constraint(equalTo: topAnchor),
            nasaImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            nasaImageView.widthAnchor.constraint(equalToConstant: 100),
            nasaImageView.heightAnchor.constraint(equalToConstant: 100),

            welcomeLabel.topAnchor.constraint(equalTo: nasaImageView.bottomAnchor, constant: 16),
            welcomeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            welcomeTextLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 16),
            welcomeTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            welcomeTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            welcomeTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func loadImage(from url: URL) {
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            self.nasaImageView.image = cachedImage
        } else {
            Task {
                if let data = try? await fetchData(from: url), let image = UIImage(data: data) {
                    ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
                    await MainActor.run {
                        self.nasaImageView.image = image
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
