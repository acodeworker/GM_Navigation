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
    
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.present(MyLocationViewController.init(), animated: true)
  }

}

