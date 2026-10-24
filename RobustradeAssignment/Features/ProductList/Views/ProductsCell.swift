//
//  ProductsCell.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//


import UIKit

final class ProductCell: UITableViewCell {
    
    static let reuseIdentifier = "ProductCell"
    private var representedURL: URL?
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                productImageView,
                stackTextView
            ]
        )
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var stackTextView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                nameLabel,
                descriptionLabel,
                categoryLabel,
                priceLabel
            ]
        )
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 8
            ),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8
            ),
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func configure(viewStateModel: ProductDetailsModel) {
        nameLabel.text = viewStateModel.title
        descriptionLabel.text = viewStateModel.description
        categoryLabel.text = viewStateModel.category
        priceLabel.text = viewStateModel.price?.displayPrice
        representedURL = viewStateModel.image?.imageUrl
        productImageView.image = UIImage(systemName: "photo")
        
        guard let imageUrl = viewStateModel.image?.imageUrl else { return }
        
        ImageLoader.shared.loadImage(from: imageUrl) {
            [weak self] image in
            
            guard let self,
                  self.representedURL == imageUrl else {
                return
            }
            
            self.productImageView.image =
            image ?? UIImage(systemName: "photo")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        representedURL = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
        categoryLabel.text = nil
        priceLabel.text = nil
        productImageView.image = UIImage(systemName: "photo")
    }
}
