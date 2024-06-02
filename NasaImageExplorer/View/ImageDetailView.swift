//
//  ImageDetailView.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//

import UIKit

class ImageDetailView: UIViewController {
    private let viewModel: ImageDetailViewModel

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let photographerLabel = UILabel()
    private let locationLabel = UILabel()

    init(viewModel: ImageDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupView()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        view.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, descriptionLabel, photographerLabel, locationLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupBindings() {
        imageView.image = UIImage(data: try! Data(contentsOf: viewModel.image.imageURL))
        titleLabel.text = viewModel.image.title
        descriptionLabel.text = viewModel.image.description
        photographerLabel.text = viewModel.image.photographer
        locationLabel.text = viewModel.image.location
    }
}
