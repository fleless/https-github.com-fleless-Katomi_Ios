//
//  Patient.swift
//  kat
//
//  Created by amine on 8/31/18.
//  Copyright © 2018 factor619. All rights reserved.
//

import Foundation

class Patient {
    var id: String
    var patientName: String
    var numberOfConsultaions: String
    var firstConsultation: String
    var nextUpdate: String
    
    init(id: String, patientName: String, numberOfConsultaions: String, firstConsultation: String, nextUpdate: String) {
        self.id = id
        self.patientName = patientName
        self.numberOfConsultaions = numberOfConsultaions
        self.firstConsultation = firstConsultation
        self.nextUpdate = nextUpdate
    }
}
