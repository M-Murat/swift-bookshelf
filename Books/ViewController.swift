//
//  ViewController.swift
//  Books
//
//  Created by Мария on 08.07.17.
//  Copyright © 2017 Мария. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Google

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var logOutFromGoogleButton: UIButton!
    
    let menager = DatabaseManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // FB login
        self.fbLoginButton.delegate = self
        self.fbLoginButton.readPermissions = ["public_profile"]
        self.fbLoginButton.publishPermissions = ["publish_actions"]
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fbProfileChanged(sender:)),
            name: NSNotification.Name.FBSDKProfileDidChange,
            object: nil)
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)

        
        // If we have a current Facebook access token, force the profile change handler
        if ((FBSDKAccessToken.current()) != nil)
        {
            self.fbProfileChanged(sender: self)
        }
        else {
            //if user logged in from google
            if User.shared.isLoggedIn(){
                self.nextButton.isHidden = false
                self.signInButton.isEnabled = false
                self.logOutFromGoogleButton.isHidden = false
            }
            else {
            // if user did not log in
                self.nextButton.isHidden = true
                self.signInButton.isEnabled = true
                self.logOutFromGoogleButton.isHidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //facebooks functions
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error != nil)
        {
            print( "\(error.localizedDescription)" )
        }
        else if (result.isCancelled)
        {
            // Logged out?
            print( "Login Cancelled")
            self.nextButton.isHidden = true
        }
        else
        {
            // Logged in?
            print( "Logged in, segue now")
            self.performSegue(withIdentifier: "showHome", sender: self)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        User.shared.image = nil
        User.shared.id = nil
        User.shared.name =  ""
        self.nextButton.isHidden = true
        self.signInButton.isEnabled = true
        print ("logged out of facebook")
    }
    
    func fbProfileChanged(sender: AnyObject!) {
        let fbProfile = FBSDKProfile.current()
        if (fbProfile != nil)
        {
            // Fetch & format the profile picture
            if let  strProfilePicURL = fbProfile?.imageURL(for: .normal, size: UIScreen.main.bounds.size) {
                var image: UIImage? = nil
                if let url = URL(string: strProfilePicURL.absoluteString, relativeTo: URL(string: "http://graph.facebook.com/")) {
                    if let imageData = try? Data(contentsOf: url) {
                        image = UIImage(data: imageData)
                    }
                }
                User.shared.image = image
            }
            User.shared.id = fbProfile!.userID
            User.shared.name =  fbProfile!.name
        }
        
        self.nextButton.isHidden = false
        self.signInButton.isEnabled = false
        self.logOutFromGoogleButton.isHidden = true
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if User.shared.isLoggedIn() {
            self.performSegue(withIdentifier: "showHome", sender: self)
        }
    }
    
    //google functions
    public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!){
        if (error != nil)
        {
            print( "\(error.localizedDescription)" )
        }
        else if User.shared.isLoggedIn(){
            self.performSegue(withIdentifier: "showHome", sender: self)
        }
    }

    @IBAction func didTapSignOutFromGoogle(_ sender: Any) {
        
        User.shared.image = nil
        User.shared.id = nil
        User.shared.name =  ""
        self.nextButton.isHidden = true
        print ("logged out of google")
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        self.logOutFromGoogleButton.isHidden = true
        self.signInButton.isEnabled = true
    }

    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if (error == nil) {
            // Perform any operations on signed in user here.
            User.shared.id = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            User.shared.name = user.profile.name
            
            if let  strProfilePicURL = user.profile.imageURL(withDimension: 300) {
                var image: UIImage? = nil
                if let url = URL(string: strProfilePicURL.absoluteString, relativeTo: URL(string: "http://graph.facebook.com/")) {
                    if let imageData = try? Data(contentsOf: url) {
                        image = UIImage(data: imageData)
                    }
                }
                User.shared.image = image
            }
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            // ...
            
            self.logOutFromGoogleButton.isHidden = false
            self.nextButton.isHidden = false
            self.signInButton.isEnabled = false
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(didDisconnectWithUser user:GIDGoogleUser!,
              withError error: Error!) {
        User.shared.image = nil
        User.shared.id = nil
        User.shared.name =  ""
        self.nextButton.isHidden = true
        self.signInButton.isEnabled = true
        self.logOutFromGoogleButton.isHidden = true
        print ("logged out of google")
    }

}

