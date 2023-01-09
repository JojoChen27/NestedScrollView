//
//  ScrollViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/8.
//

import UIKit

protocol ScrollViewController {
    var scrollView: UIScrollView { get }
    var delegate: ScrollViewControllerDelegate? { get set }
    init(delegate: ScrollViewControllerDelegate?)
}

protocol ScrollViewControllerDelegate: NSObjectProtocol {
    func scrollViewControllerDidChangeContentSize(_ scrollViewController: ScrollViewController)
}
