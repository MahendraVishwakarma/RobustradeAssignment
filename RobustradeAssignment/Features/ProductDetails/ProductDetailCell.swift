//
//  ProductDetailCell.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//

import UIKit

final class ProductDetailCell: UITableViewCell {
    
    static let reuseIdentifier = "ProductDetailCell"
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
        label.font = .systemFont(ofSize: 12, weight: .medium)
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
    
    private lazy var brandLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stockLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var specsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                productImageView,
                nameLabel,
                descriptionLabel,
                categoryLabel,
                priceLabel,
                brandLabel,
                stockLabel,
                specsLabel,
                ratingLabel
            ]
        )
        stack.axis = .vertical
        stack.spacing = 8
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
        
        self.selectionStyle = .none
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
            productImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            productImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configure(viewStateModel: ProductDetailsModel) {
        nameLabel.text = viewStateModel.title
        descriptionLabel.text = viewStateModel.description
        categoryLabel.text = "Category: " + (viewStateModel.category ?? "").capitalized
        priceLabel.text = viewStateModel.price?.displayPrice
        brandLabel.text = "Brand: " + (viewStateModel.brand ?? "").capitalized
        stockLabel.text = "Stock: " + (viewStateModel.stock?.stringValue ?? "")
        let rate = viewStateModel.rating?.rate ?? 0.0
        let count = viewStateModel.rating?.count ?? 0
        ratingLabel.text = "⭐ \(rate.formatted(.number.precision(.fractionLength(1)))) (\(count) reviews)"
        
        let waterproofText = (viewStateModel.specs?.waterproof ?? false) ? "Yes" : "No"

            specsLabel.text = """
            Color: \(viewStateModel.specs?.color?.capitalized ?? "")
            Battery: \(viewStateModel.specs?.battery ?? "")
            Waterproof: \(waterproofText)
            """
        
        representedURL = viewStateModel.resolvedImageURL
        productImageView.image = UIImage(systemName: "photo")
        
        guard let imageUrl = viewStateModel.resolvedImageURL else { return }
        
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
        brandLabel.text = nil
        stockLabel.text = nil
        ratingLabel.text = nil
        specsLabel.text = nil
        productImageView.image = UIImage(systemName: "photo")
    }
}
