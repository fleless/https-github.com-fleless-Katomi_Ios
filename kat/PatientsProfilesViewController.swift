//
//  PatientsProfilesViewController.swift
//  kat
//
//  Created by amine on 8/30/18.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ACFloatingTextfield_Swift

class PatientsProfilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: ACFloatingTextfield!
    var patients: [Patient] = Array()
    var tOriginalPatientsList: [Patient] = Array()
    struct minMax {
        var min: String
        var max: String
    }
    enum LINE_POSITION {
        case LINE_POSITION_TOP
        case LINE_POSITION_BOTTOM
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        self.title = "Patients"
        GetPatientList()
        //add right icon
        searchTextField.rightViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = UIImage(named: "search")
        searchTextField.rightView = imageView
        
        //add bottom bar
        self.addLineToView(view: searchTextField, position: .LINE_POSITION_BOTTOM, color: UIColor.lightGray, width: 0.5)
        
        //add hint
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search by username..",
                                                                   attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                                                                                NSAttributedStringKey.font : UIFont(name: (searchTextField.font?.fontName)!, size: 17)!])
        
        searchTextField.font = UIFont(name: (searchTextField.font?.fontName)!, size: 17)!
        searchTextField.textColor = UIColor.darkGray
        
        searchTextField.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 144; // set to whatever your "average" cell height is
    }
    
    @objc func searchRecords(_ textField: UITextField){
        self.patients.removeAll()
        if textField.text?.count != 0 {
            for str in tOriginalPatientsList {
                if let countryToSearch = textField.text{
                    let range = str.patientName.lowercased().range(of: countryToSearch, options: .caseInsensitive, range: nil, locale: nil)
                    if (range != nil) {
                        self.patients.append(str)
                    }
                }
            }
        } else {
            for str in tOriginalPatientsList {
                patients.append(str)
            }
        }
        tableView.reloadData()
        if (patients.count == 0){
            searchTextField.showError();
        }
    }
    
    func addLineToView(view : UIView, position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection
        section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let patient = patients[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientCell") as! PatientTableViewCell
        
        cell.setPatients(patient: patient)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! ProfilePatientViewController
        vc.id = patients[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
            }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         return true
    }
    
    func GetPatientList() {
        
        let url = URL(string: AppDelegate.url + "/patients")
        
        
        let headers: HTTPHeaders = [
            "Content-Type":"application/json"
        ]
        Alamofire.request("https://api.katomi.co/v1/patients", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result{
                case .failure(let error):
                    print("\(error)erreur")
                    let alert = UIAlertController(title: "Erreur", message: "Vérifiez votre connexion", preferredStyle: UIAlertControllerStyle.alert)
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
                case .success(let value):
                    do{
                        let jsonKbira = JSON(value)
                        for res in jsonKbira["data"]{
                            let lien = AppDelegate.url+"/patients/\(res.1["_id"])"
                            GetPatientList(lien: lien, patientid: res.1["_id"].string!)
                            }
                    }
                }
        }
        
        func GetPatientList(lien: String, patientid: String) {
            Alamofire.request(lien, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result{
                    case .failure( _):
                        let alert = UIAlertController(title: "Erreur", message: "Vérifiez vos données", preferredStyle: UIAlertControllerStyle.alert)
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
                    case .success(let value):
                        do{
                            let json = JSON(value)
                            print("salem \(json)")
                            //let nbrConsul = json["data"]["consultations"].array!
                            var consul:[String] = []
                            for item in json["data"]["consultations"]{
                                if (!consul.contains(item.1.string!)){
                                    consul.append(item.1.string!)
                                }
                            }
                            let nbrConsul = consul
                            var firstC: String = ""
                            var lastC: String = ""
                            self.getMinMax(patientId: patientid){ response in
                                print("curva \(response)")
                                 firstC = response.min
                                 lastC = response.max
                            
                            let id = json["data"]["_id"].string!
                            let firstName = json["data"]["firstName"].string!
                            let lastName = json["data"]["lastName"].string!
                            self.patients.append(Patient(id: id, patientName: "\(firstName) \(lastName)", numberOfConsultaions: "\(nbrConsul.count) consultations", firstConsultation: String(firstC.prefix(10)), nextUpdate: String(lastC.prefix(10))))
                            self.tOriginalPatientsList = self.patients
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        }
                    }
                }
        }
                    }
    
    func getMinMax(patientId: String, completion: @escaping (minMax) -> Void) {
        let min = "1900-01-01T00:00:00.000Z"
        let max = "1900-01-01T00:00:00.000Z"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var minF = dateFormatter.date(from: min)
        var maxF = dateFormatter.date(from: max)
            let url = AppDelegate.url+"/consultations/pt/"+patientId
            let headers: HTTPHeaders = [
                "Content-Type":"application/json"
            ]
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .responseJSON{ response in
                    switch response.result{
                    case .failure(let error):
                        print("\(error)erreur")
                        let alert = UIAlertController(title: "Erreur", message: "Problème de connexion", preferredStyle: UIAlertControllerStyle.alert)
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
                    case .success(let value):
                        do{
                            let jsonKbira = JSON(value)
                            for res in jsonKbira["data"]{
                            let datee = res.1["date"].string!
                            let date = dateFormatter.date(from: datee)
                            if(minF! == dateFormatter.date(from: min)){
                                minF = date
                            }
                            if(date! > maxF!){
                                maxF = date
                            }else if(date! < minF!){
                                minF = date
                            }
                        }
                            DispatchQueue.main.async {
                                completion(minMax(min: dateFormatter.string(from: minF!), max: dateFormatter.string(from: maxF!)))
                            }
                    }
                }
            }
 
        }
    
}
