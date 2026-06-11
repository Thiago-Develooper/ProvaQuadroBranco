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
    func showError(_ error: String)
}

class ViewController: UIViewController {

    private var tableView = UITableView()
    private var posts: [ArticleEntity] = []

    let presenter: PresenterHomeViewProtocol
    let router: RouterProtocol

    init(presenter: PresenterHomeViewProtocol, router: RouterProtocol) {
        self.presenter = presenter
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Top Headlines"
        view.backgroundColor = .systemBackground
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await presenter.fetchPosts()
        }
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(NewsTableViewCell.self,
                           forCellReuseIdentifier: NewsTableViewCell.identifier)
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
}

extension ViewController: HomeViewControllerProtocol {

    func showPosts(_ posts: [ArticleEntity]) {
        self.posts = posts
        self.tableView.reloadData()
    }

    func showError(_ error: String) {
        print(error)
    }
}

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
        let article = posts[indexPath.row]
        router.pushToDetail(from: self, article: article)
    }
}

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
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 3
        return label
    }()

    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
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
