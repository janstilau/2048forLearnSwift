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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let tempView = ScoreView.init(backgroundColor: UIColor.red, textColor: UIColor.black, font: UIFont.systemFont(ofSize: 11), radius: 2)
        view.addSubview(tempView)
    }

    @IBAction func startNewGame(_ sender: AnyObject) {
        
        let game = NumberTileGameViewController(dimension: 5, threshold: 2048)
        present(game, animated: true, completion: nil)
    }

}

