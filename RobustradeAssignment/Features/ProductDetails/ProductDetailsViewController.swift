//
//  ProductDetailsViewController.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//
import UIKit

final class ProductDetailsViewController: UIViewController {
    private let tableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<Section, ProductDetailsModel>!
    private let product: ProductDetailsModel
    
    init(product: ProductDetailsModel) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTableView()
        setupDataSource()
        applySnapshot(with: self.product)
        self.title = "Product Details"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(ProductDetailCell.self, forCellReuseIdentifier: ProductDetailCell.reuseIdentifier)
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, product) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProductDetailCell.reuseIdentifier, for: indexPath
            ) as? ProductDetailCell else {
                return UITableViewCell()
            }
            cell.configure(viewStateModel: product)
            return cell
        }
    }
    
    private func applySnapshot(with product: ProductDetailsModel) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductDetailsModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems([product], toSection: .main)
        
        // Animates automatically based on diff
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
