//
//  ExamplePageViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/8.
//

import UIKit
import Parchment
import EasySwiftHook

class ExamplePageViewController: UIViewController {
    
    var viewControllers: [UIViewController] {
        [controller0, controller1, controller2]
    }
    
    let controller0 = {
        let controller = ExampleViewController()
        controller.contentControllers = [
            ThreeViewController(title: "One", delegate: controller, maxNumberOfRows: 300),
            ThreeViewController(title: "Two", delegate: controller, maxNumberOfRows: 200),
            ThreeViewController(title: "Three", delegate: controller, maxNumberOfRows: 500),
            ThreeViewController(title: "Four", delegate: controller, maxNumberOfRows: 500),
        ]
        return controller
    }()
    
    let controller1 = {
        let controller = ExampleViewController()
        controller.contentControllers = [
            OneViewController(),
            TwoViewController(),
            ThreeViewController(delegate: controller),
            ThreeViewController(title: "Four", delegate: controller, maxNumberOfRows: 500),
        ]
        return controller
    }()
    
    let controller2 = {
        let controller = ExampleViewController()
        controller.contentControllers = [
            ThreeViewController(title: "One", delegate: controller, maxNumberOfRows: 300),
            ThreeViewController(title: "Two", delegate: controller, maxNumberOfRows: 200),
            ThreeViewController(title: "Three", delegate: controller, maxNumberOfRows: 500),
            ThreeViewController(title: "Four", delegate: controller, maxNumberOfRows: 500),
        ]
        return controller
    }()
    
    /// 手势处理
    /// 快速滑动子视图时, 到临界点有点停顿
    /// 快速滑动主视图时, 子视图可能无法响应直接略过
    typealias OriginalGestureRecognizerShouldBegin = (AnyObject, Selector, UIGestureRecognizer) -> Bool
    typealias NewGestureRecognizerShouldBegin = @convention(block) (OriginalGestureRecognizerShouldBegin, AnyObject, Selector, UIGestureRecognizer) -> Bool
    let gestureRecognizerShouldBeginClosure: NewGestureRecognizerShouldBegin = { original, object, selector, gestureRecognizer in
        guard let view = gestureRecognizer.view as? UIScrollView, view.panGestureRecognizer == gestureRecognizer else {
            return original(object, selector, gestureRecognizer)
        }
        
        let velocityX = view.panGestureRecognizer.velocity(in: view).x
        if velocityX > 0 {
            if view.contentOffset.x <= 0 {
                return false
            }
        } else if velocityX < 0 {
            if view.contentOffset.x >= view.contentSize.width - view.frame.width {
                return false
            }
        }
        
        return original(object, selector, gestureRecognizer)
    }
    
    func setupGestureRecognizerShouldBeginHook(with scrollView: UIScrollView) {
        do {
            try hookInstead(object: scrollView, selector: #selector(UIScrollView.gestureRecognizerShouldBegin(_:)), closure: gestureRecognizerShouldBeginClosure)
        } catch let error {
            print(error)
        }
    }
    
    override func viewDidLoad() {
        let pageViewController = PageViewController()
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.scrollView.bounces = false
        pageViewController.scrollView.delaysContentTouches = false
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        
        setupGestureRecognizerShouldBeginHook(with: controller0.pagingViewController.pageViewController.scrollView)
        setupGestureRecognizerShouldBeginHook(with: controller1.pagingViewController.pageViewController.scrollView)
        setupGestureRecognizerShouldBeginHook(with: controller2.pagingViewController.pageViewController.scrollView)
        
        // 延迟执行, 否则有 UITableView 警告
        DispatchQueue.main.async {
            pageViewController.selectViewController(self.viewControllers[0], direction: .none)
        }
    }
}

extension ExamplePageViewController: PageViewControllerDataSource {
    func pageViewController(
        _: PageViewController,
        viewControllerBeforeViewController viewController: UIViewController
    ) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else { return nil }
        // 支持无线滚动
        if index > 0 {
            return viewControllers[index - 1]
        } else {
            return viewControllers[viewControllers.count - 1]
        }
    }

    func pageViewController(
        _: PageViewController,
        viewControllerAfterViewController viewController: UIViewController
    ) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else { return nil }
        // 支持无线滚动
        if index < viewControllers.count - 1 {
            return viewControllers[index + 1]
        } else {
            return viewControllers[0]
        }
    }
}

extension ExamplePageViewController: PageViewControllerDelegate {
    func pageViewController(_: PageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController) {
        print("willStartScrollingFrom: ",
              startingViewController.title ?? "",
              destinationViewController.title ?? "")
    }

    func pageViewController(_: PageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
        print("isScrollingFrom: ",
              startingViewController.title ?? "",
              destinationViewController?.title ?? "",
              progress)
    }

    func pageViewController(_: PageViewController, didFinishScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        print("didFinishScrollingFrom: ",
              startingViewController.title ?? "",
              destinationViewController.title ?? "",
              transitionSuccessful)
    }
}
