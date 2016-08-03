//
//  profileVC.swift
//  MobileDez Social
//
//  Created by David Zielski on 8/2/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class profileVC: UIViewController {

  
  @IBOutlet weak var profileImg: CircleView!
  @IBOutlet weak var profileName: FancyFieldTextBox!
  
  @IBOutlet weak var profileSaveBtn: FancyButton!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
  @IBAction func saveBtnTapped(_ sender: AnyObject) {
  }
  
  
  @IBAction func cancelBtnTapped(_ sender: AnyObject) {
    
    performSegue(withIdentifier: "goToFeedFrProfile", sender: nil)
    
  }
  
  @IBAction func clkImgBtnTapped(_ sender: AnyObject) {
  }
  
  
  
  
  
  
  
}
