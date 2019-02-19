
//
//  CalendarConsultation.swift
//  kat
//
//  Created by amine on 10/18/18.
//  Copyright © 2018 factor619. All rights reserved.
//

import Foundation


class CalendarConsultation {
    
    var date: String
    var time: String
    var patientFullName: String
    var motif: String
    
    init(patientFullName: String, date: String, time: String, motif: String) {
        self.patientFullName = patientFullName
        self.date = date
        self.time = time
        self.motif = motif
    }
}
