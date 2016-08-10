//
//  HelpVC.swift
//  MobileDez Social
//
//  Created by David Zielski on 8/9/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class HelpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  @IBAction func cancelBtnTapped(_ sender: AnyObject) {
    performSegue(withIdentifier: "helpToFeed", sender: nil)
  }


}
