//
//  Created by fahmex on 9/11/18.
//  Copyright © 2018 fahmex. All rights reserved.
//

import UIKit
import SimpleImageViewer
import Alamofire
import SwiftyJSON

class TimeLineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var compareBtn: CustomUIbutton!
    @IBOutlet weak var compareView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var etat: Int = 0
    var rand = [#imageLiteral(resourceName: "person"),#imageLiteral(resourceName: "logo"),#imageLiteral(resourceName: "homme"),#imageLiteral(resourceName: "shingles")]
    var selectedPhotos: [UIImage] = []
    
    var consultations: [Consultation] = Array()
    var consultationIDS: [String] = Array()
    var consultationImages: [[String]] = Array()
    var base64Images: [[String]] = Array()
    var consultationMOTIFES: [String] = Array()
    var criterias: [Criteria] = Array()
    var criteriaText: [String] = Array()
    var criteriasIndex = Int()
    var cache:NSCache<AnyObject, AnyObject>!
    var index_c: Int!
    var id: String!
    var nomPatient: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nomPatient
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 320
        self.compareBtn.isEnabled = false
        self.cache = NSCache()
        GetConsultations()
    }
    
    
    func GetConsultations() {
        let url = AppDelegate.url+"/consultations/pt/"+id!
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
                            let _id = res.1["_id"].string!
                            let date = res.1["date"].string!
                            let patientID = res.1["patient"].string!
                            var purposeID:String
                            if let consultationPurpose = res.1["consultationPurpose"].string {
                                purposeID = consultationPurpose
                            } else {
                                purposeID = "non valide"
                            }
                            var textC = String()
                            var tDate = String()
                            var tTime = String()
                            tDate = date.substring(with: 0..<10)
                            tTime = date.substring(with: 11..<19)
                            if let criteria = res.1["postExamIndexCriteria"].array {
                                for i in criteria {
                                    let c_name = i["index"].string!
                                    var c_value = ""
                                    if i["value"].string != nil{
                                       c_value = i["value"].string!
                                    }
                                    self.criterias.append(Criteria(c_name: c_name, c_value: c_value))
                                    textC.append(c_name + ": " + c_value + "\n")
                                }
                            } else {
                                self.criterias.append(Criteria(c_name: "", c_value: ""))
                            }
                            
                            self.consultations.append(Consultation(id: _id, patientID: _id, date: tDate, time: tTime, images: [], consultationPurpose: purposeID, criterias: textC))
                            self.consultationIDS.append(_id)
                        }
                    }
                }
                DispatchQueue.main.async {
                    print("tyty3")
                    self.GetConsultationPurposes()
                }
        }
    }
    
    func GetConsultationPurposes() {
        
        for var t in 0 ..< self.consultations.count {
            self.consultationMOTIFES.append("aucun motif")
            if (self.consultations[t].consultationPurpose == "non valide") {
            }
            else {
                let url = AppDelegate.url+"/config/c_purposes/"+self.consultations[t].consultationPurpose
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
                                var motif = String()
                                if jsonKbira["data"]["label"].string != nil{
                                motif = jsonKbira["data"]["label"].string!
                                }else {
                                    motif = "Inconnu"
                                }
                                self.consultationMOTIFES[t] = motif
                                t += 1
                            }
                        }
                }
            }
            DispatchQueue.main.async {
                print("tyty2")
                self.GetImagesPerConsultation()
            }
        }
    }
    
    func GetImagesPerConsultation() {
        for var i in 0 ..< self.consultationIDS.count {
            let url = AppDelegate.url+"/photos/c/"+self.consultationIDS[i]
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
                            var tempImageIDS: [String] = Array()
                            for res in jsonKbira["data"]{
                                let _id = res.1["_id"].string!
                                tempImageIDS.append(_id)
                            }
                            
                            self.consultationImages.append(tempImageIDS)
                            self.consultations[i].images = tempImageIDS
                            i += 1

                        }
                    }
                    DispatchQueue.main.async {
                        print("tyty1")
                        if(self.consultationImages.count == self.consultations.count){
                            print("tyty")
                            self.tableView.reloadData()
                        }
                    }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.consultations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.consultations[indexPath.row].images.count != 0){
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell") as! MainTableViewCell
        let collec:UICollectionView = cell.viewWithTag(103) as! UICollectionView
        collec.reloadData()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        collec.addGestureRecognizer(longPress)
        
        cell.motifLbl.text = self.consultationMOTIFES[indexPath.row]
        
        cell.descriptionLbl.text = self.consultations[indexPath.row].criterias
        
        cell.dateLabel.text = self.consultations[indexPath.row].date
        cell.timeLbl.text = self.consultations[indexPath.row].time
        
        return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "vide") as! UITableViewCell
            let lblDate:UILabel = cell.viewWithTag(881) as! UILabel
            lblDate.text = self.consultations[indexPath.row].date
            let lblTime:UILabel = cell.viewWithTag(880) as! UILabel
            lblTime.text = self.consultations[indexPath.row].time
            let lblMotif:UILabel = cell.viewWithTag(882) as! UILabel
            lblMotif.text = self.consultationMOTIFES[indexPath.row]

           // cell.motifLbl.text = self.consultationMOTIFES[indexPath.row]
            
            //cell.descriptionLbl.text = self.consultations[indexPath.row].criterias
            
           // cell.timeLbl.text = self.consultations[indexPath.row].date
          //  cell.dateLabel.text = self.consultations[indexPath.row].time
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cell = collectionView.superview?.superview?.superview as! MainTableViewCell
        let index = self.tableView.indexPathForRow(at: cell.center)
        return self.consultationImages[index!.row].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsideCollectionViewCell", for: indexPath) as! InsideCollectionViewCell
        let tableCell = collectionView.superview?.superview?.superview as! MainTableViewCell
        let index = self.tableView.indexPathForRow(at: tableCell.center)
        let img:UIImageView = cell.viewWithTag(101) as! UIImageView
        img.image = #imageLiteral(resourceName: "vide")
        let key = "\(String(describing: index))col\(indexPath)"
        if (self.cache.object(forKey: key as AnyObject) != nil){
            img.image = self.cache.object(forKey: key as AnyObject) as? UIImage
        }else{
        getImage(index: (index?.row)!, second: indexPath.row) { response in
            if let updateCell = collectionView.cellForItem(at: indexPath) {
                    if let tablecell = self.tableView.cellForRow(at: index!){
                        let res:UIImage! = response
                        let imag:UIImageView = updateCell.viewWithTag(101) as! UIImageView
                        imag.image = res
                        tablecell.setNeedsLayout()
                        self.cache.setObject(res, forKey: key as AnyObject)
                        }
                    }
                }
            }
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        img.layer.borderWidth = 2
        img.layer.borderColor = UIColor(red:10/255, green:15/255, blue:59/255, alpha: 1).cgColor
        let checkZone:UIImageView = cell.viewWithTag(109) as! UIImageView
        if(etat==0){
                        checkZone.isHidden = true
                    }else{
                        checkZone.isHidden = false
                    }
        return cell
    }
    func getImage(index: Int,second: Int,completion: @escaping (UIImage) -> Void) {
        let url = AppDelegate.url+"/photos/"+self.consultationImages[index][second]
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
                        let imag = jsonKbira["data"]["image"].string!
                        DispatchQueue.main.async {
                            completion(self.ConvertBase64StringToImage(imageBase64String: imag))
                        }
                    }
                }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-40)/3 //some width
        let height = width * 1.2 //ratio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let imageView = cell?.viewWithTag(101) as! UIImageView
        if(etat==0){
            let configuration = ImageViewerConfiguration { config in
                config.imageView = imageView
            }
            let imageViewerController = ImageViewerController(configuration: configuration)
            present(imageViewerController, animated: true)
        }else{
            let imageForCheck = cell?.viewWithTag(109) as! UIImageView
            if(imageForCheck.image == #imageLiteral(resourceName: "circleChecked")){
                imageForCheck.image = #imageLiteral(resourceName: "circleVide")
                if let i = self.selectedPhotos.index(of: imageView.image!){
                    self.selectedPhotos.remove(at: i)
                }
                self.compareBtn.setTitle("Comparer(\(self.selectedPhotos.count))", for: .normal)
            }else{
                imageForCheck.image = #imageLiteral(resourceName: "circleChecked")
                self.selectedPhotos.append(imageView.image!)
            }
            self.compareBtn.setTitle("Comparer(\(self.selectedPhotos.count))", for: .normal)
            if(self.selectedPhotos.count>1){
                self.compareBtn.isEnabled = true
            }else{
                self.compareBtn.isEnabled = false
            }
        }
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if(self.etat==0){
                self.etat = 1
                tableView.reloadData()
                self.compareView.isHidden = false
            }
        }
    }
    
    @IBAction func comparer(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "compareVC") as! ComparingViewController
        vc.selectedImages = self.selectedPhotos
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func annuler(_ sender: Any) {
        self.compareView.isHidden = true
        self.selectedPhotos.removeAll()
        self.etat = 0
        self.tableView.reloadData()
        self.compareBtn.setTitle("Comparer", for: .normal)
        self.compareBtn.isEnabled = false
    }
    
    func ConvertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        
        return image!
    }
}
