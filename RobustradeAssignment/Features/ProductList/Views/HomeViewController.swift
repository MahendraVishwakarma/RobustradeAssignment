//
//  HomeViewController.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//
import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Unable to load products"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Retry"
        
        let button = UIButton(configuration: config)
        button.addTarget(
            self,
            action: #selector(retryTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var errorStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                errorLabel,
                messageLabel,
                retryButton
            ]
        )
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .red
        return indicator
    }()
    
    private lazy var tableView: UITableView = {
        UITableView()
    }()
    
    private var dataSource: UITableViewDiffableDataSource<Section, ProductDetailsModel>!
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: ProductViewModel
    
    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
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
        setupBindings()
        bindViewModel()
        viewModel.fetchProducts()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(errorStack)
        view.addSubview(activityIndicator)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            errorStack.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            errorStack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            errorStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 32
            ),
            errorStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -32
            ),
            
            activityIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            activityIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
        
        errorStack.isHidden = true
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.reuseIdentifier)
        tableView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state)
            }
            
        }
    }
    
    private func render(_ state: ProductScreenState) {
       
        switch state {
        case .loading, .idle:
            if viewModel.products.isEmpty {
                tableView.isHidden = true
                errorStack.isHidden = true
            }
            activityIndicator.startAnimating()
            
        case .loaded:
            activityIndicator.stopAnimating()
            errorStack.isHidden = true
            tableView.isHidden = false
            
        case .empty:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            errorStack.isHidden = false
            errorLabel.text = "No products found"
            messageLabel.text = "Please check back later."
            retryButton.isHidden = false
            
        case .error(let message):
            activityIndicator.stopAnimating()
            if viewModel.products.isEmpty {
                tableView.isHidden = true
                errorStack.isHidden = false
                errorLabel.text = "Unable to load products"
                messageLabel.text = message
                retryButton.isHidden = false
            } else {
                tableView.isHidden = false
                errorStack.isHidden = true
            }
        }
    }
    
    @objc private func retryTapped() {
        viewModel.reloadProducts()
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, product) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProductCell.reuseIdentifier, for: indexPath
            ) as? ProductCell else {
                return UITableViewCell()
            }
            cell.configure(viewStateModel: product)
            return cell
        }
    }
    
    private func setupBindings() {
        viewModel.$products.receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                self?.applySnapshot(with: product)
            }.store(in: &cancellables)
        
    }
    private func applySnapshot(with products: [ProductDetailsModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductDetailsModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(products, toSection: .main)
        
        // Animates automatically based on diff
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let product = dataSource.itemIdentifier(for: indexPath) else { return }
        navigationController?.pushViewController(
            ProductDetailsViewController(product: product),
            animated: true
        )
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let threshold: CGFloat = 60
        
        let distanceFromBottom =
        scrollView.contentSize.height
        - scrollView.contentOffset.y
        - scrollView.bounds.height
        
        guard distanceFromBottom < threshold else { return }
        viewModel.fetchProducts()
    }
}
