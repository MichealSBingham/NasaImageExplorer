//
//  ImageGridView.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/2/24.
//


import UIKit
import Combine




class ImageGridView: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UINavigationControllerDelegate {
    private let viewModel = ImageGridViewModel()
    private var collectionView: UICollectionView!
    private var searchBarView: SearchBarView!
    private var noResultsLabel: NoResultsLabel!
    private var welcomeView: WelcomeView!
    private var cancellables: Set<AnyCancellable> = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, NasaImage>!
    private let transition = CATransition()

    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
        updateUIForImages(viewModel.images)
        setupBackButtonAppearance()
        showSearchBarWithBounce()
        navigationController?.delegate = self
        configureTransition()
        
        // keyboard notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
   

    private func setupViews() {
        view.backgroundColor = .black

        // Welcome view
        welcomeView = WelcomeView()
        welcomeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeView)

        // No results label
        noResultsLabel = NoResultsLabel()
        view.addSubview(noResultsLabel)

        searchBarView = SearchBarView()
        searchBarView.searchBar.delegate = self
        customizeSearchBarAppearance(searchBar: searchBarView.searchBar)
        view.addSubview(searchBarView)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
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
            Task{ @MainActor in
                self?.applySnapshot()
                self?.updateUIForImages(images)
            }
               
            
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
    
    
    
    private func customizeSearchBarAppearance(searchBar: UISearchBar) {
        searchBar.barTintColor = .black
        searchBar.backgroundImage = UIImage()
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.searchTextField.backgroundColor = .black
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: searchBar.placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.clipsToBounds = true
        
        // search icon color
        if let searchIconView = searchBar.searchTextField.leftView as? UIImageView {
            searchIconView.image = searchIconView.image?.withRenderingMode(.alwaysTemplate)
            searchIconView.tintColor = .white
        }
    }

    private func setupBackButtonAppearance() {
            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            let backButton = UIBarButtonItemAppearance()
            backButton.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.backButtonAppearance = backButton
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.tintColor = .white
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            viewModel.images.removeAll()
            updateUIForImages(viewModel.images)
        }
    }
    
    private func showSearchBarWithBounce() {
        searchBarView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 1,
                       delay: 0.5,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut,
                       animations: {
                        self.searchBarView.transform = .identity
                       },
                       completion: nil)
    }

   

   

 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let query = searchBar.text, !query.isEmpty else {
           
            updateUIForImages(viewModel.images)
            return
        }
        
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
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .fade
        navigationController?.view.layer.add(transition, forKey: kCATransition)

        navigationController?.pushViewController(detailView, animated: false)
        
        //navigationController?.pushViewController(detailView, animated: true)
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
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            if operation == .pop {
                transition.subtype = .fromLeft
                navigationController.view.layer.add(transition, forKey: kCATransition)
            }
            return nil
        }
    
    
    private func configureTransition() {
            transition.duration = 0.3
            transition.type = .fade
        }
    
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        // Move the welcome view up by the height of the keyboard
        UIView.animate(withDuration: 0.3) {
            self.welcomeView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height / 3)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        // Move the welcome view back to its original position
        UIView.animate(withDuration: 0.3) {
            self.welcomeView.transform = .identity
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
