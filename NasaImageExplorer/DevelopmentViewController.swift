//
//  DevelopmentViewController.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/3/24.
//

import UIKit

class DevelopmentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example of testing ImageGridCell
        let cell = ImageGridCell(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        cell.configure(with: URL(string: "https://example.com/image.jpg")!)
        
        view.addSubview(cell)
        cell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cell.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cell.widthAnchor.constraint(equalToConstant: 100),
            cell.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        
        
    }
}
