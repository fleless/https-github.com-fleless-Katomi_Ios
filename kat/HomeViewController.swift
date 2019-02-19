//
//  HomeViewController.swift
//  kat
//
//  Created by fahmex on 29/08/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var bienvenueLbl: UILabel!
    let cameraController = CameraController()
    let cameraCaptureController = PhotoCaptureViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        bienvenueLbl.text = "Bienvenue Dr. "+AppDelegate.currentDoctor.firstname+" "+AppDelegate.currentDoctor.lastname
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func Prendredesphotos(_ sender: Any) {
        self.navigationController?.pushViewController(cameraController, animated: true)
    }
    
    @IBAction func consulterListePatients(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "patientsViewController") as! PatientsProfilesViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dossiersMedicalesPatients(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "calendar") as! CalendarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func gestionRendezVous(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "first") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ResauxInterpro(_ sender: Any) {
        print("photo")
    }
    
    @IBAction func TelechargerDesDonnees(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "picker") as! SelectFromGalleryViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
