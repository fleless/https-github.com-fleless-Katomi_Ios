//
//  PopUpViewController.swift
//  kat
//
//  Created by fahmex on 13/09/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit
import SearchTextField
import Alamofire
import SwiftyJSON
import ACFloatingTextfield_Swift

class PopUpViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var confirmerBtn: CustomUIbutton!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var labelValide: UILabel!
    @IBOutlet weak var searchMotifBtn: SearchTextField!
    var lstPhotos: [UIImage]!
    var motif: String!
    var patientId: String!
    var consultationId: String!
    var lstMotifs: [String] = []
    var lstIdMotifs: [String] = []
    var lstLblCritere: [String] = []
    var lstTypesCritere: [String] = []
    var lstValeurs: [String] = []

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return lstLblCritere.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(self.lstTypesCritere[indexPath.row] == "String"){
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Mycell", for: indexPath)
        let lbl:UILabel = cell.viewWithTag(401) as! UILabel
        lbl.text = self.lstLblCritere[indexPath.row]
        let acf:ACFloatingTextfield = cell.viewWithTag(402) as! ACFloatingTextfield
        acf.placeholder = self.lstLblCritere[indexPath.row]
        acf.addTarget(self, action: #selector(PopUpViewController.collectionTextFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            acf.text = self.lstValeurs[indexPath.row]
        if(acf.text == ""){
                acf.errorText = "invalide";acf.showError()
            }
            self.lstValeurs[indexPath.row] = acf.text!
        return cell
        }else if((self.lstTypesCritere[indexPath.row] == "Number")||(self.lstTypesCritere[indexPath.row] == "Numbre")){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath)
            let lbl:UILabel = cell.viewWithTag(501) as! UILabel
            lbl.text = self.lstLblCritere[indexPath.row]
            let acf:ACFloatingTextfield = cell.viewWithTag(502) as! ACFloatingTextfield
            acf.delegate = self as? UITextFieldDelegate
            acf.placeholder = self.lstLblCritere[indexPath.row]
            acf.text = self.lstValeurs[indexPath.row]
            acf.addTarget(self, action: #selector(PopUpViewController.collectionTextFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if(acf.text == ""){
                acf.errorText = "invalide";acf.showError()
            }
            self.lstValeurs[indexPath.row] = acf.text!
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "switchCell", for: indexPath)
            let lbl:UILabel = cell.viewWithTag(601) as! UILabel
            lbl.text = self.lstLblCritere[indexPath.row]
            let sw:UISwitch = cell.viewWithTag(602) as! UISwitch
            sw.addTarget(self, action: #selector(PopUpViewController.switchChanged(_:)), for: UIControlEvents.valueChanged)
            if(sw.isOn){
            self.lstValeurs[indexPath.row] = "true"
            }else{
                self.lstValeurs[indexPath.row] = "false"
            }
            return cell
        }
    }
    
    func textField(_ textField:UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("gramma\(consultationId)")
        if(consultationId == "pas de consultation"){
        getAllMotifs()
            print("getAll")
        }else if(motif == "pas de motif"){
        getAllMotifsWithConsultation()
            print("getAllWithConsul")
        }else{
        getMotif()
            print("getOne")
        }
        searchMotifBtn.itemSelectionHandler = {filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            self.searchMotifBtn.text = item.title
            self.confirmerBtn.isHidden = true
            self.reloadView()
        }
        searchMotifBtn.addTarget(self, action: #selector(PopUpViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    @IBAction func Quit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getAllMotifs(){
        let url = AppDelegate.url+"/config/c_purposes"
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
                    for result in json["data"].arrayValue {
                        self.lstMotifs.append(result["label"].string!)
                        self.lstIdMotifs.append(result["_id"].string!)
                    }
                    self.searchMotifBtn.filterStrings(self.lstMotifs)
                }
        }
    }
    
    func getMotif(){
        let url = AppDelegate.url+"/config/c_purposes/\(motif!)"
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
                    self.searchMotifBtn.text = json["data"]["label"].string!
                    self.lstMotifs.append(json["data"]["label"].string!)
                    self.lstIdMotifs.append(json["data"]["_id"].string!)
                    self.searchMotifBtn.isEnabled = false
                }
                DispatchQueue.main.async {
                    self.reloadView()
                }
        }
    }
    
    func getAllMotifsWithConsultation(){
        let url = AppDelegate.url+"/config/c_purposes"
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
                    for result in json["data"].arrayValue {
                        self.lstMotifs.append(result["label"].string!)
                        self.lstIdMotifs.append(result["_id"].string!)
                    }
                    self.searchMotifBtn.filterStrings(self.lstMotifs)
                }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
            reloadView()
    }
    
    func reloadView(){
        if(lstMotifs.contains(searchMotifBtn.text!.trimmed)){
            if(self.searchMotifBtn.isEnabled == true){
                OverlayView()
            }
            self.labelValide.isHidden = true
            self.collection.isHidden = false
            self.confirmerBtn.isHidden = false
            loadCriteres()
        }else{
            self.labelValide.isHidden = false
            self.collection.isHidden = true
            self.confirmerBtn.isHidden = true
        }
    }
    
    func loadCriteres(){
        self.lstLblCritere.removeAll()
        self.lstTypesCritere.removeAll()
        self.lstValeurs.removeAll()
        motif = self.searchMotifBtn.text
        let index = lstMotifs.index(of: motif)
        let url = AppDelegate.url+"/config/c_purposes/\(self.lstIdMotifs[index!])"
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
                    for result in json["data"]["indexationCriteria"].arrayValue {
                        self.lstLblCritere.append(result["label"].string!)
                        self.lstTypesCritere.append(result["type"].string!)
                        self.lstValeurs.append("")
                    }
                    DispatchQueue.main.async {
                        if(self.searchMotifBtn.isEnabled == true){
                        self.dismiss(animated: true, completion: nil)
                        }
                        self.collection.reloadData()
                    }
                }
        }
    }

    @IBAction func goConfirmer(_ sender: Any) {
        self.confirmerBtn.isEnabled = false
        valid()
        var validation:Bool = true
        print(self.lstValeurs)
        for item in self.lstValeurs{
            if (item == ""){
                validation = false
            }
        }
        if(validation == false){
            let alert = UIAlertController(title: "Invalide", message: "Veuillez remplir tous les criteres", preferredStyle: UIAlertControllerStyle.alert)
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
            self.confirmerBtn.isEnabled = true
        }else{
            var  cartProducts = [AnyObject]()
            for item in self.lstValeurs{
                let paramsArray = ["index": self.lstLblCritere[self.lstValeurs.index(of: item)!], "value": item]
                //let paramsJSON = JSON(paramsArray)
                //let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: .init(rawValue: 0))
                cartProducts.append(paramsArray as AnyObject)
            }
            print("cartPro:\(cartProducts)")
            let indexation = self.lstMotifs.index(of: self.motif!)
            let ok = self.lstIdMotifs[indexation!]
            let url = AppDelegate.url+"/consultations/\(self.consultationId!)"
            let parametres = [
                "consultationPurpose": ok,
                "postExamIndexCriteria": cartProducts
                ] as [String : Any]
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONSerialization.data(withJSONObject: parametres, options: JSONSerialization.WritingOptions.prettyPrinted)
            Alamofire.request(request)
                .responseJSON{ response in
                    switch response.result{
                    case .failure(let error):
                        print("\(error.localizedDescription)erreur")
                        self.confirmerBtn.isEnabled = true
                    case .success( _):
                        self.saveImages()
                }
            }
        }
    }
    
    func valid() {
        for cell in collection.visibleCells as [UICollectionViewCell] {
            let index = self.collection.indexPath(for: cell)
            if(self.lstTypesCritere[(index?.row)!] == "String"){
                let acf = cell.viewWithTag(402) as! ACFloatingTextfield!
                if(acf?.text == ""){
                    acf?.errorText = "invalide";acf?.showError()
                }
            }else if((self.lstTypesCritere[(index?.row)!] == "Number")||(self.lstTypesCritere[(index?.row)!] == "Numbre")){
                let acf = cell.viewWithTag(502) as! ACFloatingTextfield!
                if(acf?.text == ""){
                    acf?.errorText = "invalide";acf?.showError()
                }
            }else{
            }
        }
    }
    
    @objc func collectionTextFieldDidChange(_ textField: UITextField){
        guard let cellInAction = textField.superview?.superview as? UICollectionViewCell else { return }
        guard let indexPath = collection?.indexPath(for: cellInAction) else { return }
        self.lstValeurs[indexPath.row] = textField.text!
    }
    
    @objc func switchChanged(_ swittch: UISwitch){
        guard let cellInAction = swittch.superview?.superview as? UICollectionViewCell else { return }
        guard let indexPath = collection?.indexPath(for: cellInAction) else { return }
        if(swittch.isOn){
        self.lstValeurs[indexPath.row] = "true"
        }else{
            self.lstValeurs[indexPath.row] = "false"
        }
    }
    
    func saveImages(){
        for items in self.lstPhotos{
            let url = AppDelegate.url+"/photos"
        let parametres = [
            "image": ConvertImageToBase64String(img: items),
            "patient":self.patientId!,
            "consultation":self.consultationId!
            ] as [String : Any] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type":"application/json"
        ]
            Alamofire.request(url, method: .post, parameters: parametres, encoding: JSONEncoding.default, headers: headers)
                .responseJSON{ response in
                    switch response.result{
                    case .failure(let error):
                        let alert = UIAlertController(title: "Erreur", message: "Connexion trop lente", preferredStyle: UIAlertControllerStyle.alert)
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
                        self.confirmerBtn.isEnabled = true
                        print("\(error.localizedDescription)erreur")
                    case .success(let value):
                        _ = JSON(value)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "logged") as! UINavigationController
                        self.present(vc, animated: true, completion: nil)
                    }
            }
        }
    }

    //
    // Convert String to base64
    //
    func ConvertImageToBase64String (img: UIImage) -> String {
        let imageData:NSData = UIImageJPEGRepresentation(img, 0.50)! as NSData //UIImagePNGRepresentation(img)
        let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
        return imgString
    }

    //
    // Convert base64 to String
    //
    func ConvertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }

}

extension String {
    var trimmed:String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}


