//
//  IgnoreIndexPagingViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/8.
//

import Parchment

open class IgnoreIndexPagingViewController: PagingViewController {
    
    /// 设置之后, index > ignoreIndex 的页面不得滑动过去
    /// 点击 index 的 item, 也只会响应代理方法
    public var ignoreIndex: Int?
    
    open override func pageViewController(_: PageViewController, viewControllerAfterViewController _: UIViewController) -> UIViewController? {
        guard
            let dataSource = infiniteDataSource,
            let currentPagingItem = state.currentPagingItem,
            let pagingItem = dataSource.pagingViewController(self, itemAfter: currentPagingItem) else { return nil }
        if let item = (pagingItem as? PagingIndexItem), let index = ignoreIndex, item.index >= index {
            return nil
        }
        return dataSource.pagingViewController(self, viewControllerFor: pagingItem)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = visibleItems.pagingItem(for: indexPath) as? PagingIndexItem, let index = ignoreIndex, item.index >= index {
            delegate?.pagingViewController(self, didSelectItem: item)
            return
        }
        super.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    open var currentViewController: UIViewController? {
        guard let pagingItem = state.currentPagingItem else {
            return nil
        }
        return infiniteDataSource?.pagingViewController(self, viewControllerFor: pagingItem)
    }
}
