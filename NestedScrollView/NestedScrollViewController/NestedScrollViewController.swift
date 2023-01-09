//
//  NestedScrollViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/6.
//

import UIKit
import Parchment
import SnapKit

protocol NestedScrollViewControllerDataSource {
    var headerViewHeight: CGFloat { get }
    var headerView: UIView { get }
    var viewControllers: [UIViewController] { get }
}


class NestedScrollViewController:
    UIViewController,
    NestedScrollViewControllerDataSource,
    UIScrollViewDelegate,
    PagingViewControllerDelegate,
    ScrollViewControllerDelegate {
    
    private var viewControllerOffsets: [UIViewController: CGFloat] = [:]
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .white
        view.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        view.refreshControl = refreshControl
        return view
    }()
    
    lazy var pagingViewController = {
        let pagingViewController = IgnoreIndexPagingViewController(viewControllers: viewControllers)
        pagingViewController.pageViewController.scrollView.bounces = false
        pagingViewController.delegate = self
        return pagingViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(headerView)
        addChild(pagingViewController)
        scrollView.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.leading.width.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }
        pagingViewController.view.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let viewController = pagingViewController.currentViewController as? ScrollViewController {
            updateContentHeight(with: viewController.scrollView.contentSize.height)
        } else if let viewController = pagingViewController.currentViewController {
            viewController.view.setNeedsLayout()
            viewController.view.layoutIfNeeded()
            updateContentHeight(with: viewController.view.frame.height)
        }
    }
    
    func updateContentHeight(with subContenHeight: CGFloat) {
        var height = headerViewHeight
        height += pagingViewController.options.menuHeight
        height += subContenHeight
        scrollView.contentSize = CGSize(width: 0, height: height)
    }
    
    func updateViewOrigin(with offsetGap: CGFloat) {
        headerView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(offsetGap)
        }
    }
    
    var headerOffset: CGFloat {
        let headerOffset = headerViewHeight - scrollView.adjustedContentInset.top
        return headerOffset
    }
    
    var offsetGap: CGFloat {
        let offsetGap = scrollView.contentOffset.y - headerOffset
        return offsetGap
    }
    
    /// 头部刷新
    @objc func refresh() {
        
    }
    
    // MARK: - NestedScrollViewControllerDataSource
    var headerViewHeight: CGFloat {
        0
    }
    
    var headerView: UIView {
        UIView()
    }
    
    var viewControllers: [UIViewController] {
        []
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 更新视图位置
        updateViewOrigin(with: max(offsetGap, 0))
        
        // 清空缓存的偏移
        if offsetGap < 0 {
            viewControllerOffsets = [:]
            viewControllers.forEach { viewController in
                if let scrollViewController = viewController as? ScrollViewController {
                    scrollViewController.scrollView.contentOffset = .zero
                }
            }
        }
        // 更新当前的 sub scrollView
        else if let viewController = pagingViewController.currentViewController as? ScrollViewController {
            viewController.scrollView.contentOffset = CGPoint(x: 0, y: max(offsetGap, 0))
        }
    }
    
    // MARK: - PagingViewControllerDelegate
    
    func pagingViewController(
        _: PagingViewController,
        isScrollingFromItem currentPagingItem: PagingItem,
        toItem upcomingPagingItem: PagingItem?,
        startingViewController: UIViewController,
        destinationViewController: UIViewController?,
        progress: CGFloat
    ) {
        // 滚动过程中设置 view.frame
        if let destinationViewController = destinationViewController, progress != 0 {
            let gap = destinationViewController.view.frame.height - startingViewController.view.frame.height
            if gap != 0 {
                let height = startingViewController.view.frame.height + gap * abs(progress)
                updateContentHeight(with: height)
            }
        }
    }
    
    func pagingViewController(
        _ pagingViewController: PagingViewController,
        didScrollToItem pagingItem: PagingItem,
        startingViewController: UIViewController?,
        destinationViewController: UIViewController,
        transitionSuccessful: Bool
    ) {
        // 过度成功设置 destinationViewController
        if transitionSuccessful {
            if let viewController = destinationViewController as? ScrollViewController {
                // 先保持上一个
                if offsetGap > 0, let startingViewController = startingViewController, startingViewController is ScrollViewController {
                    viewControllerOffsets[startingViewController] = scrollView.contentOffset.y
                }
                
                // 再更新当前的 ContentHeight
                updateContentHeight(with: viewController.scrollView.contentSize.height)
                
                // 设置当前的偏移
                if let offset = viewControllerOffsets[destinationViewController] {
                    scrollView.contentOffset.y = offset
                } else if offsetGap > 0 {
                    scrollView.contentOffset.y = headerOffset
                }
            }
        }
        // 过度失败恢复 ContentHeight
        else {
            if let viewController = startingViewController as? ScrollViewController {
                // 再更新当前的 ContentHeight
                updateContentHeight(with: viewController.scrollView.contentSize.height)
            }
        }
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        
    }
    
    // MARK: - ScrollViewControllerDelegate
    
    func scrollViewControllerDidChangeContentSize(_ scrollViewController: ScrollViewController) {
        if let viewController = scrollViewController as? UIViewController, viewController == pagingViewController.currentViewController {
            updateContentHeight(with: scrollViewController.scrollView.contentSize.height)
        }
    }
}
