//
//  LoginViewController.swift
//  kat
//
//  Created by fahmex on 28/08/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift
import Alamofire
import SwiftyJSON
import M13Checkbox

class LoginViewController: UIViewController {

    @IBOutlet weak var rememberMeCheckBox: M13Checkbox!
    @IBOutlet weak var mdpOublie: UIButton!
    @IBOutlet weak var connexion: CustomUIbutton!
    @IBOutlet weak var mdp: ACFloatingTextfield!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var email: ACFloatingTextfield!
    var currentDoctor : Doctor = Doctor()

    override func viewDidLoad() {
        super.viewDidLoad()
        signUp.titleLabel?.minimumScaleFactor = 0.5
        signUp.titleLabel?.numberOfLines = 1
        signUp.titleLabel?.adjustsFontSizeToFitWidth = true
        mdpOublie.titleLabel?.minimumScaleFactor = 0.5
        mdpOublie.titleLabel?.numberOfLines = 1
        mdpOublie.titleLabel?.adjustsFontSizeToFitWidth = true
        mdpOublie.contentHorizontalAlignment = .center
        mdpOublie.contentVerticalAlignment = .center
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "email") == nil {
        } else {
            email.text = preferences.string(forKey: "email")
            mdp.text = preferences.string(forKey: "password")
        }
    }

    @IBAction func forgotPassword(_ sender: UIButton) {
        if(isValidEmailAddress(emailAddressString: email.text!)){
            
        }else{
            email.errorText = "Vérifiez votre email";email.showError()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func goLogin(_ sender: CustomUIbutton) {
        if(valid()){
            OverlayView()
            let url = AppDelegate.url + "/auth/login"
            let url2 = URL(string: AppDelegate.url + "/auth/login")
            self.connexion.isEnabled = false
            func setCookies(cookies: HTTPCookie){
                Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies([cookies], for: url2 , mainDocumentURL: nil)
            }
            let parametres = [
                "email": email.text!,
                "password":mdp.text!
            ]
            let headers: HTTPHeaders = [
                "Content-Type":"application/json"
            ]
            Alamofire.request(url, method: .post, parameters: parametres, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    //self.saveCookies(response: response)
                    switch response.result{
                    case .failure(let error):
                        self.dismiss(animated: true, completion: nil)
                        self.connexion.isEnabled = true
                        let alert = UIAlertController(title: "Erreur", message: "Verifier votre connexion", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                            case .default:
                                print("default")
                            case .cancel:
                                print("cancel")
                            case .destructive:
                            print("destructive")
                            }
                        }))
                    self.present(alert, animated: true, completion: nil)
                    case .success(let value):
                        self.auth()
                }
            }
        }
    }
    
    func valid() -> Bool {
        if ((!(mdp.text?.isEmpty)!)&&(isValidEmailAddress(emailAddressString: email.text!)))
        {
            return true
        }else{
            if((mdp.text?.isEmpty)!){mdp.errorText = "tapez un password";mdp.showError()}
            if((!isValidEmailAddress(emailAddressString: email.text!))){email.errorText = "Vérifiez votre email";email.showError()}
            return false
        }
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    @IBAction func signUp(_ sender: Any) {
        
    }
    
    func saveCookies(response: DataResponse<Any>) {
        let headerFields = response.response?.allHeaderFields as! [String: String]
        let url = response.response?.url
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        for cookie in cookies {
            cookieArray.append(cookie.properties!)
        }
        UserDefaults.standard.set(cookieArray, forKey: "savedCookies")
        UserDefaults.standard.synchronize()
    }
    
    func loadCookies() {
        guard let cookieArray = UserDefaults.standard.array(forKey: "savedCookies") as? [[HTTPCookiePropertyKey: Any]] else { return }
        for cookieProperties in cookieArray {
            if let cookie = HTTPCookie(properties: cookieProperties) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    func auth(){
        let url = AppDelegate.url+"/auth"
        let headers: HTTPHeaders = [
            "Content-Type":"application/json"
        ]
        //loadCookies()
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
            .responseJSON{ response in
                switch response.result{
                case .failure(let error):
                    print("\(error.localizedDescription)erreur")
                case .success(let value):
                    print("defil2")
                    let json = JSON(value)
                    let preferences = UserDefaults.standard
                    if(self.rememberMeCheckBox._IBCheckState == "Checked"){
                    preferences.set(self.email.text, forKey: "email")
                    preferences.set(self.mdp.text, forKey: "password")
                    preferences.synchronize()
                    }else{
                        preferences.removeObject(forKey: "email")
                        preferences.removeObject(forKey: "password")
                    }
                    self.currentDoctor.firstname = json["user"]["firstName"].string!
                    self.currentDoctor.lastname = json["user"]["lastName"].string!
                    self.currentDoctor.email = json["user"]["email"].string!
                    AppDelegate.currentDoctor = self.currentDoctor
                    self.dismiss(animated: true){
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "logged") as! UINavigationController
                    self.present(vc, animated: true, completion: nil)
                    }
                }
        }
    }
    
}
