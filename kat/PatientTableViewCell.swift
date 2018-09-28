//
//  PatientTableViewCell.swift
//  kat
//
//  Created by amine on 8/31/18.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit

class PatientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var numberOfPictures: UILabel!
    @IBOutlet weak var firstConsultation: UILabel!
    @IBOutlet weak var nextUpdate: UILabel!
    @IBOutlet weak var patientName: UILabel!
    
    func setPatients(patient: Patient) {
        patientName.text = patient.patientName
        numberOfPictures.text = patient.numberOfConsultaions
        firstConsultation.text = patient.firstConsultation
        nextUpdate.text = patient.nextUpdate
    }
}
