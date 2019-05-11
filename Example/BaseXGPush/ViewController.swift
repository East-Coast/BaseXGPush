//
//  ViewController.swift
//  BaseXGPush
//
//  Created by East-Coast on 05/09/2019.
//  Copyright (c) 2019 East-Coast. All rights reserved.
//

import UIKit

import XGPush_Swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        let notifi = XGNotificationAction.init()
        print(notifi)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

