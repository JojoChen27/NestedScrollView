//
//  ThreeViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/6.
//

import UIKit
import NestedScrollViewController

class LoadingCell: UITableViewCell {
    
    let indicatorView = UIActivityIndicatorView(style: .medium)
    
    let label = {
        let label = UILabel()
        label.text = "没有更多数据了!"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(indicatorView)
        contentView.addSubview(label)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ThreeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ScrollViewController {
    
    var numberOfRows = 100
    
    var maxNumberOfRows = 500
    
    var scrollView: UIScrollView {
        tableView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return numberOfRows
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(LoadingCell.self)", for: indexPath) as! LoadingCell
            if noMore {
                cell.indicatorView.isHidden = true
                cell.label.isHidden = false
            } else {
                cell.label.isHidden = true
                cell.indicatorView.startAnimating()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
            cell.textLabel?.text = "Title \(indexPath.row)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == numberOfRows - 10 {
            loadMore()
        }
    }
    
    var isLoading = false
    
    var noMore = false
    
    func loadMore() {
        guard !isLoading, !noMore else { return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.numberOfRows += 100
            self.tableView.reloadData()
            self.isLoading = false
            if self.numberOfRows >= self.maxNumberOfRows {
                self.noMore = true
            }
        }
    }
    
    init(title: String, maxNumberOfRows: Int) {
        super.init(nibName: nil, bundle: nil)
        self.maxNumberOfRows = maxNumberOfRows
        self.title = title
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Three"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        view.register(LoadingCell.self, forCellReuseIdentifier: "\(LoadingCell.self)")
        // 如果MainScrollView.bottom == view.bottom, 可以这样设置安全距离
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        view.estimatedRowHeight = 0
        view.rowHeight = 44
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print(title!, #function)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print(title!, #function)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        print(title!, #function)
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        print(title!, #function)
//    }
}
