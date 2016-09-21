//
//  ViewController.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let tempView = ScoreView.init(backgroundColor: UIColor.redColor(), textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(11), radius: 2)
        view.addSubview(tempView)
    }

    @IBAction func startNewGame(sender: AnyObject) {
        
        let game = NumberTileGameViewController(dimension: 5, threshold: 2048)
        presentViewController(game, animated: true, completion: nil)
    }

}

