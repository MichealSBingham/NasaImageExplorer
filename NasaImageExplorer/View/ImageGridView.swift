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
    private var noResultsLabel: NoResultsLabel!
    private var welcomeView: WelcomeView!
    private var cancellables: Set<AnyCancellable> = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, NasaImage>!

    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
        updateUIForImages(viewModel.images)
    }

    private func setupViews() {
        view.backgroundColor = .white

        // Welcome view
        welcomeView = WelcomeView()
        welcomeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeView)

        // No results label
        noResultsLabel = NoResultsLabel()
        view.addSubview(noResultsLabel)

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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            welcomeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        viewModel.$images.sink { [weak self] images in
            self?.applySnapshot()
            self?.updateUIForImages(images)
        }.store(in: &cancellables)
    }

    private func updateUIForImages(_ images: [NasaImage]) {
        
        
        
        //If no images + searchBar is empty, show welcome view
        if images.isEmpty && searchBarView.searchBar.text?.isEmpty ?? true {
            showWelcomeView()
        }
        
        if images.isEmpty  && !(searchBarView.searchBar.text?.isEmpty ?? true) {
            showNoResultsMessage()
        }
        
        if !(images.isEmpty) &&  !(searchBarView.searchBar.text?.isEmpty ?? true)  {
            showResults()
        }
        
       
        
       
    }

    private func showWelcomeView() {
        welcomeView.isHidden = false
        noResultsLabel.isHidden = true
        collectionView.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.welcomeView.alpha = 1.0
        }
    }

    private func showNoResultsMessage() {
        welcomeView.isHidden = true
        noResultsLabel.isHidden = false
        collectionView.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.noResultsLabel.alpha = 1.0
        }
    }

    private func showResults() {
        
        welcomeView.isHidden = true
        noResultsLabel.isHidden = true
        collectionView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.collectionView.alpha = 1.0
        }
    }
    
    private func hideWelcomeViewAndNoResultsMessage() {
        print("hiding welcome view and no results")
        welcomeView.isHidden = true
        noResultsLabel.isHidden = true
        collectionView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.collectionView.alpha = 1.0
        }
    }
    
    
   

    // UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search bar clicked")
        guard let query = searchBar.text, !query.isEmpty else {
            print("updating UI")
            updateUIForImages(viewModel.images)
            return
        }
        print("searching \(searchBar.text)")
        Task {
            await viewModel.searchImages(query: query)
        }
        searchBar.resignFirstResponder()
    }

    // UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        
        guard indexPath.item < viewModel.images.count else {
            // Index is out of range, do nothing or show an error
            return
        }
        

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
