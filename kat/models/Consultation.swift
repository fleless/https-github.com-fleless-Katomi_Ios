//
//  Consultation.swift
//  kat
//
//  Created by amine on 9/17/18.
//  Copyright © 2018 factor619. All rights reserved.
//

import Foundation


class Consultation {
    var id: String
    var patientID: String
    var date: String
    var time: String
    var images: [String]
    var consultationPurpose: String
    var criterias: String
    
    init(id: String, patientID: String, date: String, time: String, images: [String], consultationPurpose: String, criterias: String) {
        self.id = id
        self.patientID = patientID
        self.date = date
        self.time = time
        self.images = images
        self.consultationPurpose = consultationPurpose
        self.criterias = criterias
    }
}
