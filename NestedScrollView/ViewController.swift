//
//  ViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/6.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pushAction(_ sender: Any) {
        // 用这个是列表, 支持加载更多
        let controller = ExampleViewController()
        controller.contentControllers = [
            ThreeViewController(title: "One", delegate: controller, maxNumberOfRows: 300),
            ThreeViewController(title: "Two", delegate: controller, maxNumberOfRows: 200),
            ThreeViewController(title: "Three", delegate: controller, maxNumberOfRows: 500),
            ThreeViewController(title: "Four", delegate: controller, maxNumberOfRows: 500),
        ]
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func pushCustomView(_ sender: Any) {
        // 用这个每个内容视图的高度不同
        let controller = ExampleViewController()
        controller.contentControllers = [
            OneViewController(),
            TwoViewController(),
            ThreeViewController(delegate: controller),
            ThreeViewController(title: "Four", delegate: controller, maxNumberOfRows: 500),
        ]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func pushPageView(_ sender: Any) {
        // 整页无线滚动
        let controller = ExamplePageViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

