//
//  ViewController.swift
//  OrderDepthChart
//
//  Created by Julian Jäger on 19.11.18.
//  Copyright © 2018 Yoshi Jäger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func openButtonTaooed(_ sender: Any) {
        let vc = ExampleViewController()
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

