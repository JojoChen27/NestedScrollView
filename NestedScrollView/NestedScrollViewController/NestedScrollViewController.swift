//
//  NestedScrollViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/6.
//

import UIKit
import Parchment

public protocol NestedScrollViewControllerDataSource {
    /// 头部视图高度
    var headerViewHeight: CGFloat { get }
    /// 头部视图
    var headerView: UIView { get }
    /// 子控制器
    /// 只支持静态创建控制器传值使用, 无法使用PagingViewController的数据源
    var viewControllers: [UIViewController] { get }
    /// 用于MainScrollView布局, 表示顶部内边距偏移
    var topInset: CGFloat { get }
    /// 用于Main ScrollView布局, 表示底部内边距偏移
    var bottomInset: CGFloat { get }
}


open class NestedScrollViewController:
    UIViewController,
    NestedScrollViewControllerDataSource,
    UIScrollViewDelegate,
    PagingViewControllerDelegate {
    
    public var viewControllerOffsets: [UIViewController: CGFloat] = [:]
    
    public lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    public lazy var pagingViewController = {
        let pagingViewController = IgnoreIndexPagingViewController(viewControllers: viewControllers)
        pagingViewController.delegate = self
        return pagingViewController
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(headerView)
        addChild(pagingViewController)
        scrollView.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        makeConstraints()
        
        viewControllers.forEach {
            guard let scrollView = ($0 as? ScrollViewController)?.scrollView else { return }
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.new], context: nil)
            scrollView.isScrollEnabled = false
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIScrollView.contentSize) {
            if let scrollView = (object as? UIScrollView) {
                let viewController = viewControllers.compactMap({ $0 as? ScrollViewController }).first(where: { $0.scrollView == scrollView })
                if let viewController = viewController as? UIViewController, viewController == pagingViewController.currentViewController {
                    let height = actualContentHeight(with: scrollView)
                    updateContentHeight(with: height)
                }
            }
        }
    }
    
    deinit {
        viewControllers.forEach {
            guard let scrollView = ($0 as? ScrollViewController)?.scrollView else { return }
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let viewController = pagingViewController.currentViewController as? ScrollViewController {
            let height = actualContentHeight(with: viewController.scrollView)
            updateContentHeight(with: height)
        } else if let viewController = pagingViewController.currentViewController {
            viewController.view.setNeedsLayout()
            viewController.view.layoutIfNeeded()
            updateContentHeight(with: viewController.view.frame.height)
        }
    }
    
    public var headerViewTopConstraint: NSLayoutConstraint?
    public var headerViewHeightConstraint: NSLayoutConstraint?
    public var topInsetConstraint: NSLayoutConstraint?
    public var bottomInsetConstraint: NSLayoutConstraint?
    
    open func makeConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let topInsetConstraint = scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset)
        self.topInsetConstraint = topInsetConstraint
        let bottomInsetConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomInset)
        self.bottomInsetConstraint = bottomInsetConstraint
        let headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0)
        self.headerViewTopConstraint = headerViewTopConstraint
        let headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerViewHeight)
        self.headerViewHeightConstraint = headerViewHeightConstraint
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topInsetConstraint,
            bottomInsetConstraint,
            headerViewTopConstraint,
            headerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            headerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            headerViewHeightConstraint,
            pagingViewController.view.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            pagingViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            pagingViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            pagingViewController.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    open func actualContentHeight(with scrollView: UIScrollView) -> CGFloat {
        var height = scrollView.contentSize.height
        height += scrollView.contentInset.bottom
        height += scrollView.contentInset.top
        return max(height, scrollView.frame.height)
    }
    
    open func updateContentHeight(with subContenHeight: CGFloat) {
        var height = headerViewHeight
        height += pagingViewController.options.menuHeight
        height += subContenHeight
        scrollView.contentSize = CGSize(width: 0, height: height)
    }
    
    open func updateViewOrigin(with offsetGap: CGFloat) {
        headerViewTopConstraint?.constant = offsetGap
    }
    
    open var offsetGap: CGFloat {
        let offsetGap = scrollView.contentOffset.y - headerViewHeight
        return offsetGap
    }
    
    // MARK: - NestedScrollViewControllerDataSource
    open var headerViewHeight: CGFloat {
        0
    }
    
    open var headerView: UIView {
        UIView()
    }
    
    open var viewControllers: [UIViewController] {
        []
    }
    
    open var topInset: CGFloat {
        0
    }
    
    open var bottomInset: CGFloat {
        0
    }
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollView.scrollsToTop
    }
    
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    }
    
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
    }
    
    
    // MARK: - PagingViewControllerDelegate
    
    open func pagingViewController(
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
    
    open func pagingViewController(_: PagingViewController, willScrollToItem pagingItem: PagingItem, startingViewController: UIViewController, destinationViewController: UIViewController) {
    }
    
    open func pagingViewController(
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
                let height = actualContentHeight(with: viewController.scrollView)
                updateContentHeight(with: height)
                
                // 设置当前的偏移
                if let offset = viewControllerOffsets[destinationViewController] {
                    scrollView.contentOffset.y = offset
                } else if offsetGap > 0 {
                    scrollView.contentOffset.y = headerViewHeight
                }
            }
        }
        // 过度失败恢复 ContentHeight
        else {
            if let viewController = startingViewController as? ScrollViewController {
                // 再更新当前的 ContentHeight
                let height = actualContentHeight(with: viewController.scrollView)
                updateContentHeight(with: height)
            }
        }
    }
    
    open func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
    }
}
