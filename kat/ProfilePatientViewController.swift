//
//  ProfilePatientViewController.swift
//  kat
//
//  Created by fahmex on 04/09/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfilePatientViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lstAntecedentsTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "antecell", for: indexPath)
        let lbl:UILabel = cell.viewWithTag(141) as! UILabel
        lbl.text = self.lstAntecedentsTags[indexPath.row]
        let msg:UITextView = cell.viewWithTag(140) as! UITextView
        msg.text = self.lstAntecedentsDesc[indexPath.row]
        return cell
    }
    
    @IBOutlet weak var collectionAntecedents: UICollectionView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var anniversaire: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var adresse: UILabel!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var profession: UILabel!
    @IBOutlet weak var statut: UILabel!
    @IBOutlet weak var enfants: UILabel!
    var id: String!
    var lstAntecedentsTags : [String] = []
    var lstAntecedentsDesc : [String] = []
    var testString : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        print("mamamia\(id)")
        let url = AppDelegate.url+"/patients/"+id
        let headers: HTTPHeaders = [
            "Content-Type":"application/json"
        ]
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
            .responseJSON{ response in
                switch response.result{
                case .failure(let error):
                    print("\(error.localizedDescription)erreur")
                case .success(let value):
                    let json = JSON(value)
                    var bDate: String
                    var bDateSub: String
                    if let birthdate = json["data"]["birthDate"].string {
                        bDate = json["data"]["birthDate"].string!
                        bDateSub = String(bDate.prefix(10))
                    }
                    else {
                        bDateSub = "date indisponible"
                    }
                    var fcDate: String
                    var fcDateSub: String
                    if let birthdate = json["data"]["firstConsultation"].string {
                        fcDate = json["data"]["firstConsultation"].string!
                        fcDateSub = String(fcDate.prefix(10))
                    }
                    else {
                        fcDateSub = "date indisponible"
                    }
                    self.fullName.text = json["data"]["firstName"].string!+" "+json["data"]["lastName"].string!
                    self.anniversaire.text = bDateSub
                    if json["data"]["email"].string != nil{
                    self.email.text = json["data"]["email"].string!
                    }else{self.email.text = "email indisponible"}
                    if json["data"]["address"].string != nil {
                    self.adresse.text = json["data"]["address"].string!
                    }else{self.adresse.text = "adresse indisponible"}
                    if json["data"]["phoneNumber"].string != nil{
                    self.tel.text = json["data"]["phoneNumber"].string!
                    }else{self.tel.text = "numero indisponible"}
                    if json["data"]["profession"].string != nil{
                    self.profession.text = json["data"]["profession"].string!
                    }else{self.profession.text = "profession indisponible"}
                    if json["data"]["maritalStatus"].string != nil{
                    self.statut.text = json["data"]["maritalStatus"].string!
                    }else{self.statut.text = "statut indisponible"}
                    if json["data"]["numberOfChildren"].string != nil{
                    self.enfants.text = json["data"]["numberOfChildren"].string!
                    }else{self.enfants.text = "numero d'enfants indisponible"}
                    let ante = json["data"]["antecedents"];
                    for res in ante {
                        self.lstAntecedentsTags.append(res.0)
                        self.testString = ""
                        if(res.0 == "test"){
                          self.testString += "      true \n"
                        }else{
                        for lines in res.1{
                            self.testString += "      \(lines.0) \n"
                        }
                            self.lstAntecedentsDesc.append(self.testString)
                        }
                    }
                    self.collectionAntecedents.reloadData()
                }
        }
    }
    
    @IBAction func goTimeLine(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "timeLine") as! TimeLineViewController
        vc.id = self.id
        vc.nomPatient = self.fullName.text
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func sendMail(_ sender: Any) {
        if let url = URL(string: "mailto:\(String(describing: self.email.text))") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func appeler(_ sender: Any) {
        if let url = URL(string: "tel://\(self.tel.text!)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}
