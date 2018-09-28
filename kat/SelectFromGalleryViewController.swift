//
//  SelectFromGalleryViewController.swift
//  Katomi
//
//  Created by fahmex on 8/2/18.
//  Copyright © 2018 factory619. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker
import SimpleImageViewer
import SearchTextField
import Alamofire
import SwiftyJSON

class SelectFromGalleryViewController: UIViewController , UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CropViewControllerDelegate {
    
    @IBOutlet weak var searchTextField: SearchTextField!
    var lstPatients = [String]()
    var lstPhotos: [UIImage]!
    var lstIdPatients = [String]()


    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        PhotoArray.remove(at: indx)
        PhotoArray.insert(image, at: indx)
        collection.reloadData()
       }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var btnEnregistrer: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    var SelectedAssets = [PHAsset]()
    var PhotoArray = [UIImage]()
    var indx: Int = 0
    @IBOutlet weak var selectionnerBtn: CustomUIbutton!
    
    @IBAction func choosePatient(_ sender: Any) {
        self.btnEnregistrer.isEnabled = false
        if((self.PhotoArray.count > 0)&&(self.lstPatients.contains(self.searchTextField.text!))){
            let index = self.lstPatients.index(of: self.searchTextField.text!)
            getConsultaions(index: index!)
        }else{
            let message: String
            if(self.PhotoArray.count == 0){
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
            self.btnEnregistrer.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.theme.font = UIFont.systemFont(ofSize: 15)
        searchTextField.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6)
        btnEnregistrer.titleLabel?.minimumScaleFactor = 0.5
        btnEnregistrer.titleLabel?.numberOfLines = 1
        btnEnregistrer.titleLabel?.adjustsFontSizeToFitWidth = true
        selectionnerBtn.titleLabel?.minimumScaleFactor = 0.5
        selectionnerBtn.titleLabel?.numberOfLines = 1
        selectionnerBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        collection.addGestureRecognizer(longPress)
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
                    }
                    print(self.lstPatients)
                    self.searchTextField.filterStrings(self.lstPatients)
                }
        }
            }
    
    @IBAction func addImagesClicked(_ sender: Any) {
        self.PhotoArray.removeAll()
        self.SelectedAssets.removeAll()
        self.collection.reloadData()
        // create an instance
        let vc = BSImagePickerViewController()
        
        //display picture gallery
        self.bs_presentImagePickerController(vc, animated: true,
                                             select: { (asset: PHAsset) -> Void in
                                                
        }, deselect: { (asset: PHAsset) -> Void in
            // User deselected an assets.
            
        }, cancel: { (assets: [PHAsset]) -> Void in
            // User cancelled. And this where the assets currently selected.
        }, finish: { (assets: [PHAsset]) -> Void in
            // User finished with these assets
            for i in 0..<assets.count
            {
                self.SelectedAssets.append(assets[i])
            }
            self.convertAssetToImages()
        }, completion: nil)
    }
    
    func convertAssetToImages() -> Void {
        if SelectedAssets.count != 0{
            for i in 0..<SelectedAssets.count{
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: SelectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                })
                let data = UIImageJPEGRepresentation(thumbnail, 0.7)
                let newImage = UIImage(data: data!)
                self.PhotoArray.append(newImage! as UIImage)
            }
            DispatchQueue.main.async {
                self.collection.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.PhotoArray.count > 0){
            return self.PhotoArray.count
        }
        else {
            return 1
        }
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let img:UIImageView = cell.viewWithTag(201) as! UIImageView
        if(self.PhotoArray.count > 0){
            DispatchQueue.main.async {
            img.image = self.PhotoArray[indexPath.row]
            }
        }else{
            img.image = #imageLiteral(resourceName: "vide")
        }
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        img.layer.borderWidth = 3
        img.layer.borderColor = UIColor.white.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width - 20) / 3 //some width
        let height = width * 1.5 //ratio
        return CGSize(width: width, height: height)
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(self.PhotoArray.count > 0){
        let imageView = UIImageView(image: self.PhotoArray[indexPath.row])
        imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        imageView.isHidden = true
        view.addSubview(imageView)
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        
        present(imageViewerController, animated: true)
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if(self.PhotoArray.count > 0){
                let point = sender.location(in: self.collection)
                indx = (self.collection.indexPathForItem(at: point)?.row)!
                    let menu = UIMenuController.shared
                    becomeFirstResponder()
                let MenuItemDelete = UIMenuItem(title: "Delete", action: #selector(deleteTapped))
                let MenuItemCrop = UIMenuItem(title: "Crop", action: #selector(cropTapped))
                menu.menuItems = [MenuItemDelete,MenuItemCrop]
                   let location = sender.location(in: sender.view)
                      let menuLocation = CGRect(x: location.x,y: location.y,width: 0, height: 0)
                    menu.setTargetRect(menuLocation, in: sender.view!)
                    menu.setMenuVisible(true, animated: true)
            }
        }
    }
 
    @objc func deleteTapped() {
        let refreshAlert = UIAlertController(title: "Supprimer la photo", message: "Sure de vouloir supprimer la photo? ", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (action: UIAlertAction!) in
            print(self.indx)
            self.PhotoArray.remove(at: self.indx)
            self.collection.reloadData()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: { (action: UIAlertAction!) in
            
            refreshAlert .dismiss(animated: true, completion: nil)
            
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    @objc func cropTapped() {
        let controller = CropViewController()
        controller.delegate = self
        controller.image = PhotoArray[indx]
        
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
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
                            self.btnEnregistrer.isEnabled = true
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
                modalVc.lstPhotos = self.PhotoArray
                modalVc.consultationId = cons
                modalVc.motif = motif
                modalVc.patientId = id
                self.btnEnregistrer.isEnabled = true
                self.present(modalVc, animated: true, completion: nil)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: { (action: UIAlertAction!) in
                self.btnEnregistrer.isEnabled = true
                refreshAlert .dismiss(animated: true, completion: nil)
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }else{
            let refreshAlert = UIAlertController(title: "RDV déja fixé", message: "un RDV est déja fixé , veuillez lui attribuer un motif", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (action: UIAlertAction!) in
                let modalVc = self.storyboard?.instantiateViewController(withIdentifier: "popUp") as! PopUpViewController
                modalVc.modalPresentationStyle = .overCurrentContext
                modalVc.lstPhotos = self.PhotoArray
                modalVc.consultationId = cons
                modalVc.motif = motif
                modalVc.patientId = id
                self.btnEnregistrer.isEnabled = true
                self.present(modalVc, animated: true, completion: nil)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: { (action: UIAlertAction!) in
                self.btnEnregistrer.isEnabled = true
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
                    modalVc.lstPhotos = self.PhotoArray
                    modalVc.consultationId = json["data"]["_id"].string!
                    modalVc.motif = "pas de motif"
                    modalVc.patientId = id
                    self.btnEnregistrer.isEnabled = true
                    self.present(modalVc, animated: true, completion: nil)
                }
        }
    }
}
