//
//  ImageGridView.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//


import UIKit
import Combine

class ImageGridView: UIViewController, UISearchBarDelegate, UICollectionViewDelegate {
    private let viewModel = ImageGridViewModel()
    private var collectionView: UICollectionView!
    private var searchBarView: SearchBarView!
    private var cancellables: Set<AnyCancellable> = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, NasaImage>!

    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
    }

    private func setupViews() {
        view.backgroundColor = .white

        searchBarView = SearchBarView()
        searchBarView.searchBar.delegate = self
        view.addSubview(searchBarView)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageGridCell.self, forCellWithReuseIdentifier: ImageGridCell.reuseIdentifier)
        collectionView.delegate = self
        view.addSubview(collectionView)

        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        configureDataSource()
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, NasaImage>(collectionView: collectionView) { (collectionView, indexPath, nasaImage) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGridCell.reuseIdentifier, for: indexPath) as! ImageGridCell
            cell.configure(with: nasaImage.thumbnailURL)
            return cell
        }

        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, NasaImage>()
        initialSnapshot.appendSections([.main])
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NasaImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.images)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func setupBindings() {
        viewModel.$images.sink { [weak self] _ in
            self?.applySnapshot()
        }.store(in: &cancellables)
    }

    // UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        Task {
            await viewModel.searchImages(query: query)
        }
        searchBar.resignFirstResponder()
    }

    // UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = viewModel.images[indexPath.item]
        let detailViewModel = ImageDetailViewModel(image: image)
        let detailView = ImageDetailView(viewModel: detailViewModel)
        navigationController?.pushViewController(detailView, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            Task {
                await viewModel.loadMoreImages()
            }
        }
    }
}

extension ImageGridView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGridCell.reuseIdentifier, for: indexPath) as! ImageGridCell
        let image = viewModel.images[indexPath.item]
        cell.configure(with: image.thumbnailURL)
        return cell
    }
}
