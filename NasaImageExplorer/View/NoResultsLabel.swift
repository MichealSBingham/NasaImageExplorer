//
//  NoResultsLabel.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/3/24.
//

import Foundation
import UIKit

class NoResultsLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        text = "No search results found."
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 18)
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}
