//
//  ImageDetailView.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//

import UIKit




class ImageDetailView: UIViewController {
    private let viewModel: ImageDetailViewModel

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let photographerView = DetailInfoView(icon: UIImage(systemName: "camera"), text: "")
    private let locationView = DetailInfoView(icon: UIImage(systemName: "location"), text: "")

    init(viewModel: ImageDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupView()
        setupNavigationBar()
        Task {
            await setupBindings()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        view.backgroundColor = .black

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        photographerView.translatesAutoresizingMaskIntoConstraints = false
        locationView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0

        photographerView.update(text: viewModel.image.photographer ?? "Photographer Unknown")
        locationView.update(text: viewModel.image.location ?? "Location Unknown")

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(photographerView)
        contentView.addSubview(locationView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 300),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            photographerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            photographerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photographerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            locationView.topAnchor.constraint(equalTo: photographerView.bottomAnchor, constant: 8),
            locationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            locationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        
    }

    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backButton.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = backButton
    }

    private func setupBindings() async {
        await loadImage()
        titleLabel.text = viewModel.image.title
        descriptionLabel.text = viewModel.image.description
        photographerView.update(text: viewModel.image.photographer ?? "Photographer Unknown")
        locationView.update(text: viewModel.image.location ?? "Location Unknown")
    }

    private func loadImage() async {
        let url = viewModel.image.imageURL
        if let data = try? await fetchData(from: url), let image = UIImage(data: data) {
            ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
            await MainActor.run {
                self.imageView.image = image
            }
        }
    }

    private func fetchData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

