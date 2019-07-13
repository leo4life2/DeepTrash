//
//  MenuViewController.swift
//  TrashClassifier
//
//  Created by Leo on 2019/7/14.
//  Copyright © 2019 leo. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toId"{
            let dest = segue.destination as! ViewController
            dest.menuVC = self
        } else {
            let dest = segue.destination as! GameViewController
            dest.menuVC = self
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
