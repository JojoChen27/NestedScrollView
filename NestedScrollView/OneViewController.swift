//
//  OneViewController.swift
//  NestedScrollView
//
//  Created by 陈超 on 2023/1/6.
//

import UIKit

class OneViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "One"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // view.frame 需要这里设置
        view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: 500))
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
