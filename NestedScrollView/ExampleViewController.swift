//
//  ExampleViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/6.
//

import UIKit
import SnapKit
import Parchment

class ExampleViewController: NestedScrollViewController, PagingViewControllerSizeDelegate {
    
    
    lazy var _headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        let button = UIButton()
        button.setTitle("测试", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()
    
    var contentControllers: [UIViewController] = []
    
    /// 返回头部高度
    override var headerViewHeight: CGFloat {
        500
    }
    
    /// 返回头部视图
    override var headerView: UIView {
        _headerView
    }
    
    /// 返回内容控制器
    override var viewControllers: [UIViewController] {
        contentControllers
    }
    
    lazy var itemWidthCache = {
        return self.contentControllers.map {
            let title = $0.title ?? ""
            let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.pagingViewController.options.menuItemSize.height)
            let attributes = [NSAttributedString.Key.font: self.pagingViewController.options.font]
            
            let rect = title.boundingRect(
                with: size,
                options: .usesLineFragmentOrigin,
                attributes: attributes,
                context: nil
            )
            let width = ceil(rect.width)
            return width
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 忽略 index >= 3 的页面
        pagingViewController.ignoreIndex = 3
        
        // Menu 设置风格
        pagingViewController.sizeDelegate = self
        pagingViewController.font = .systemFont(ofSize: 14)
        pagingViewController.selectedFont = .systemFont(ofSize: 14)
        pagingViewController.textColor = UIColor(red: 0.443, green: 0.443, blue: 0.478, alpha: 1)
        pagingViewController.selectedTextColor = UIColor(red: 0.054, green: 0.68, blue: 0.597, alpha: 1)
        pagingViewController.indicatorColor = UIColor(red: 0.054, green: 0.68, blue: 0.597, alpha: 1)
        pagingViewController.indicatorOptions = .visible(height: 2, zIndex: 1, spacing: .zero, insets: .zero)
        pagingViewController.borderOptions = .hidden
        pagingViewController.menuItemLabelSpacing = 0
        pagingViewController.menuInsets = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        pagingViewController.menuItemSpacing = max(32, (UIScreen.main.bounds.width - (itemWidthCache.reduce(0, +) + 64)) / 3)
    }
    
    func pagingViewController(_: Parchment.PagingViewController, widthForPagingItem pagingItem: Parchment.PagingItem, isSelected: Bool) -> CGFloat {
        guard let item = pagingItem as? PagingIndexItem else { return 0 }
        let width = itemWidthCache[item.index]
        return width
    }
    
    @objc func buttonAction(_ button: UIButton) {
        print(#function)
    }
    
    /// 头部刷新
    @objc override func refresh() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    /// 点击菜单
    override func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        print(pagingItem)
    }
}
