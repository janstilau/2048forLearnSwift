//
//  ViewController.swift
//  2048Self
//
//  Created by jansti on 16/9/20.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func btnAction(sender: AnyObject) {
        
        let game = NumberTileGameViewController.init(dimension: 4, threshold: 100)
        presentViewController(game, animated: true, completion: nil)
    }

}

