//
//  DetailInfoView.swift
//  NasaImageExplorer
//
//  Created by Micheal Bingham on 6/3/24.
//

import Foundation
import UIKit

class DetailInfoView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(icon: UIImage?, text: String) {
        super.init(frame: .zero)
        iconImageView.image = icon
        infoLabel.text = text
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(iconImageView)
        addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            infoLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoLabel.topAnchor.constraint(equalTo: topAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func update(text: String) {
        infoLabel.text = text
    }
}
