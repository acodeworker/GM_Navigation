//
//  ViewController.swift
//  GoogleMap_Demo
//
//  Created by jeremy on 2024/8/24.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.view.backgroundColor = .white
    view.addSubview(actionBtn)
    NSLayoutConstraint.activate([
      actionBtn.centerXAnchor.constraint(equalTo:self.view.centerXAnchor),
      actionBtn.centerYAnchor.constraint(equalTo:self.view.centerYAnchor)
    ])
  }
  
  @objc func navigateAction(){
    self.navigationController?.pushViewController(MyLocationViewController.init(), animated: true)
  }
  
  private lazy var actionBtn: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setTitle("go to Ride", for:.normal)
    btn.setTitleColor(.white, for:.normal)
    btn.backgroundColor = .red
    btn.addTarget(self, action: #selector(navigateAction), for: .touchUpInside)
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
}

