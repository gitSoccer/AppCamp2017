//
//  LoginViewController.swift
//  CacheMeIfYouCan
//
//  Created by “Camp on 6/23/17.
//  Copyright © 2017 Ethan Rosenfeld. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    var userName: String?
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
//    @IBAction func googleLogIn(_ sender: GIDSignInButton)
//    {
//        //GIDSignIn.sharedInstance().signIn()
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print("User email: " + user.email!)
                MyVariables.username = user.displayName!
                 self.performSegue(withIdentifier: "toMaps", sender: self)
                //do something with user (you are signed in)
            } else {
                //no user is signed in. show the user login screen
            }
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
