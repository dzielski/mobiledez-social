//
//  SearchUserVC.swift
//  MobileDez Social
//
//  Created by David Zielski on 8/8/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase

class SearchUserVC: UIViewController, UITextFieldDelegate {


  @IBOutlet weak var userNameTxtField: FancyFieldTextBox!
  
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
      view.addGestureRecognizer(tap)
      
      userNameTxtField.delegate = self
        // Do any additional setup after loading the view.
    }

  //Calls this function when the tap is recognized.
  func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
  }
  

  @IBAction func findUserBtnTapped(_ sender: AnyObject) {
  
    let usrname = self.userNameTxtField.text!

    DataService.ds.REF_USERS.queryOrdered(byChild: "userName").queryEqual(toValue: usrname).observeSingleEvent(of: .value, with: { (snapshot) in
      
      if snapshot.exists() {
        print("DZ: snapshot exists for \(usrname)")
        self.userNameTxtField.text! = ""
        
        let alert = UIAlertController(title: "User Name Was Found", message: "Do you want to add them to your friends list", preferredStyle: UIAlertControllerStyle.alert)

        let actionYes = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
          print("DZ: In search for username, found a match and they want to add them to their friends")
        
        }
        
        let actionNo = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
          print("DZ: In search for username, found a match but they dont want to add them to their friends")
        }
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        self.present(alert, animated: true, completion: nil)
        
      } else {
        
        let alert = UIAlertController(title: "Could Not Find User Name", message: "Please check your spelling and try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    
    })

  }

  @IBAction func cancelBtnTapped(_ sender: AnyObject) {
    self.performSegue(withIdentifier: "searchBackToProfile", sender: nil)
  
  }
  
  
  
  
}
