//
//  ViewController.swift
//  TwitterJW
//
//  Created by Jacky Wang on 7/7/16.
//  Copyright © 2016 Jacky Wang. All rights reserved.
//

import UIKit

class TJWViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        login(self)
    }

    @IBAction func login(_ sender: AnyObject) {
        TJWAPI.sharedAPI.authenticate() { success in
            guard success else {
                let alertController = UIAlertController(title: nil, message: "Please Sign in with Twitter in settings", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { _ in
                    alertController.dismiss(animated: true, completion: nil)
                    
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            self.performSegue(withIdentifier: "home", sender: nil)
        }
    }
}

