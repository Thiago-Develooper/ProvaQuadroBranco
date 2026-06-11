//
//  ViewController.swift
//  TesteVIPERsurpresaSeiro
//
//  Created by Thiago on 11/06/26.
//

import UIKit

@MainActor
protocol HomeViewControllerProtocol: AnyObject {
    func showPosts(_ posts: [ArticleEntity])
    func showLoading()
    func hideLoading()
    func showError(_ error: String)
}

class ViewController: UIViewController {

    private var tableView = UITableView()
    private var posts: [ArticleEntity] = []

    let presenter: PresenterHomeViewProtocol
    let router: RouterProtocol

    // MARK: - Loading

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Error

    private let errorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let errorIconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        let imageView = UIImageView(image: UIImage(systemName: "wifi.exclamationmark", withConfiguration: config))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Tentar novamente"
        config.cornerStyle = .capsule
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(presenter: PresenterHomeViewProtocol, router: RouterProtocol) {
        self.presenter = presenter
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Top Headlines"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupLoadingView()
        setupErrorView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await presenter.fetchPosts()
        }
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 200
        tableView.backgroundColor = .systemBackground

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupLoadingView() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupErrorView() {
        errorView.addSubview(errorIconView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            errorIconView.topAnchor.constraint(equalTo: errorView.topAnchor),
            errorIconView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorIconView.widthAnchor.constraint(equalToConstant: 56),
            errorIconView.heightAnchor.constraint(equalToConstant: 56),

            errorLabel.topAnchor.constraint(equalTo: errorIconView.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
        ])
    }

    @objc private func retryTapped() {
        Task { await presenter.fetchPosts() }
    }
}

// MARK: - HomeViewControllerProtocol

extension ViewController: HomeViewControllerProtocol {

    func showLoading() {
        errorView.isHidden = true
        tableView.isHidden = true
        loadingIndicator.startAnimating()
    }

    func hideLoading() {
        loadingIndicator.stopAnimating()
        tableView.isHidden = false
    }

    func showPosts(_ posts: [ArticleEntity]) {
        self.posts = posts
        tableView.reloadData()
    }

    func showError(_ error: String) {
        tableView.isHidden = true
        errorLabel.text = error
        errorView.isHidden = false
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for: indexPath
        ) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        router.pushToDetail(from: self, article: posts[indexPath.row])
    }
}

// MARK: - NewsTableViewCell

final class NewsTableViewCell: UITableViewCell {

    static let identifier = "NewsTableViewCell"

    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 2
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.numberOfLines = 1
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(newsImageView)
        contentView.addSubview(stack)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(authorLabel)
        stack.addArrangedSubview(descriptionLabel)
        stack.addArrangedSubview(sourceLabel)

        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            newsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            newsImageView.widthAnchor.constraint(equalToConstant: 120),
            newsImageView.heightAnchor.constraint(equalToConstant: 120),

            stack.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with article: ArticleEntity) {
        titleLabel.text = article.title
        authorLabel.text = article.author
        descriptionLabel.text = article.description
        sourceLabel.text = article.source.name

        if let urlString = article.urlToImage, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            newsImageView.image = UIImage(systemName: "photo")
        }
    }

    private func loadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let image = UIImage(data: data)
                await MainActor.run { self.newsImageView.image = image }
            } catch {
                await MainActor.run { self.newsImageView.image = UIImage(systemName: "photo") }
            }
        }
    }
}
