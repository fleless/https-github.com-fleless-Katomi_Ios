//
//  patientPopUpViewController.swift
//  kat
//
//  Created by fahmex on 27/09/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit
import SearchTextField
import Alamofire
import SwiftyJSON

class patientPopUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var confirmerBtn: CustomUIbutton!
    var lstPhotos: [UIImage]!
    var lstPatients = [String]()
    var lstIdPatients = [String]()
    @IBOutlet weak var searchTextField: SearchTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.theme.font = UIFont.systemFont(ofSize: 15)
        searchTextField.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6)
        let url = AppDelegate.url+"/patients"
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
                        let firstName = result["firstName"].stringValue
                        let lastName = result["lastName"].stringValue
                        self.lstPatients.append(firstName+" "+lastName)
                        self.lstIdPatients.append(result["_id"].stringValue)
                        print(self.lstPatients)
                    }
                    self.searchTextField.filterStrings(self.lstPatients)
                }
        }
    }

    @IBAction func outButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmer(_ sender: Any) {
        self.confirmerBtn.isEnabled = false
        if((self.lstPhotos!.count > 0)&&(self.lstPatients.contains(self.searchTextField.text!))){
            let index = self.lstPatients.index(of: self.searchTextField.text!)
            getConsultaions(index: index!)
        }else{
            let message: String
            if(self.lstPhotos.count == 0){
                message = "Choisissez au moins une photo à ajouter"
            }else{
                message = "Choisissez un patient existant"
            }
            let alert = UIAlertController(title: "Incomplet", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                }}))
            self.present(alert, animated: true, completion: nil)
            self.confirmerBtn.isEnabled = true
        }
    }
    
    func getConsultaions(index: Int){
        let id = self.lstIdPatients[index]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        let currentDate = String(myString.prefix(10))
        let url = AppDelegate.url+"/consultations/pt/\(id)"
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
                    var lstDatesC: [String] = []
                    var ConsultationId: String = "pas de consultation"
                    var motifId: String = "pas de motif"
                    for res in json["data"].arrayValue {
                        let dateC = res["date"].stringValue
                        let dateCC = String(dateC.prefix(10))
                        lstDatesC.append(dateCC)
                        if let consu = res["_id"].string{
                            if(dateCC == currentDate){
                                ConsultationId = consu
                            }
                        }
                        if let motif = res["consultationPurpose"].string{
                            if(dateCC == currentDate){
                                motifId = motif
                            }
                        }
                    }
                    if(lstDatesC.contains(currentDate)){
                        self.getMotif(id: id, cons: ConsultationId, motif: motifId)
                    }else{
                        let refreshAlert = UIAlertController(title: "Ajouter RDV", message: "Aucun Rendez-vous n'est programme pour aujourd'hui", preferredStyle: UIAlertControllerStyle.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (action: UIAlertAction!) in
                            self.ajouterConsultation(id: id)
                        }))
                        refreshAlert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: { (action: UIAlertAction!) in
                            self.confirmerBtn.isEnabled = true
                            refreshAlert .dismiss(animated: true, completion: nil)
                        }))
                        self.present(refreshAlert, animated: true, completion: nil)
                    }
                }
        }
    }
    
    func  getMotif(id: String, cons: String, motif: String){
        if(motif != "pas de motif"){
            let refreshAlert = UIAlertController(title: "RDV déja fixé", message: "un RDV est déja fixé", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (action: UIAlertAction!) in
                let modalVc = self.storyboard?.instantiateViewController(withIdentifier: "popUp") as! PopUpViewController
                modalVc.modalPresentationStyle = .overCurrentContext
                modalVc.lstPhotos = self.lstPhotos
                modalVc.consultationId = cons
                modalVc.motif = motif
                modalVc.patientId = id
                self.confirmerBtn.isEnabled = true
                self.present(modalVc, animated: true, completion: nil)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: { (action: UIAlertAction!) in
                self.confirmerBtn.isEnabled = true
                refreshAlert .dismiss(animated: true, completion: nil)
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }else{
            let refreshAlert = UIAlertController(title: "RDV déja fixé", message: "un RDV est déja fixé , veuillez lui attribuer un motif", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (action: UIAlertAction!) in
                let modalVc = self.storyboard?.instantiateViewController(withIdentifier: "popUp") as! PopUpViewController
                modalVc.modalPresentationStyle = .overCurrentContext
                modalVc.lstPhotos = self.lstPhotos
                modalVc.consultationId = cons
                modalVc.motif = motif
                modalVc.patientId = id
                self.confirmerBtn.isEnabled = true
                self.present(modalVc, animated: true, completion: nil)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: { (action: UIAlertAction!) in
                self.confirmerBtn.isEnabled = true
                refreshAlert .dismiss(animated: true, completion: nil)
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func ajouterConsultation(id: String){
        let url = AppDelegate.url+"/consultations"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let myString = formatter.string(from: Date().addingTimeInterval(-14400))
        let currentDate = String(myString.prefix(19))
        let parametres = [
            "patient": id,
            "date": currentDate
            ] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type":"application/json"
        ]
        Alamofire.request(url, method: .post, parameters: parametres, encoding: JSONEncoding.default, headers: headers)
            .responseJSON{ response in
                switch response.result{
                case .failure(let error):
                    print("\(error.localizedDescription)erreur")
                case .success( let value):
                    let json = JSON(value)
                    let modalVc = self.storyboard?.instantiateViewController(withIdentifier: "popUp") as! PopUpViewController
                    modalVc.modalPresentationStyle = .overCurrentContext
                    modalVc.lstPhotos = self.lstPhotos
                    modalVc.consultationId = json["data"]["_id"].string!
                    modalVc.motif = "pas de motif"
                    modalVc.patientId = id
                    self.confirmerBtn.isEnabled = true
                    self.present(modalVc, animated: true, completion: nil)
                }
        }
    }
}
