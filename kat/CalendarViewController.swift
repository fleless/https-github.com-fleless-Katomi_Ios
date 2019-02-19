//
//  CalendarViewController.swift
//  kat
//
//  Created by fahmex on 17/10/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit
import JBDatePicker
import Alamofire
import SwiftyJSON

class CalendarViewController: UIViewController, JBDatePickerViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dateConsul: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var datePicker: JBDatePickerView!
    @IBOutlet weak var monthLabel: UILabel!
    var consultations: [CalendarConsultation] = Array()
    var rightPatients: [CalendarConsultation] = Array()
    
    lazy var dateFormatter: DateFormatter = {
        
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        getConsultations() {response in
            self.consultations = response
            print(self.consultations[0].date)
        }
        
        datePicker = JBDatePickerView()
        view.addSubview(datePicker)
        datePicker.delegate = self
        datePicker.backgroundColor = UIColorFromRGB(rgbValue: 0x880E4F)
        datePicker.tintColor = UIColor.white
        
        //add constraints
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.heightAnchor.constraint(equalToConstant: 250).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        if #available(iOS 11.0, *) {
            datePicker.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            datePicker.topAnchor.constraint(equalTo: monthLabel.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            let topguideBottom = self.topLayoutGuide.bottomAnchor
            datePicker.topAnchor.constraint(equalTo: topguideBottom).isActive = true
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rightPatients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CalendarTableViewCell
        cell.patientName.text = self.rightPatients[indexPath.row].patientFullName+" à "+String(self.rightPatients[indexPath.row].time.prefix(5))
        //cell.consultationTime.text = self.rightPatients[indexPath.row].time
        print("daldoul")
        print(self.rightPatients[indexPath.row].motif)
        if(self.rightPatients[indexPath.row].motif == "Inconnu"){
            cell.motifLbl.text = "Inconnu"
        }else{
        getConsultationPurpose(id: self.rightPatients[indexPath.row].motif) { response in
            cell.motifLbl.text = response
        }
        }
        return cell
    }
    
    func getConsultationPurpose(id: String,completion: @escaping (String) -> Void) {
        let url = AppDelegate.url+"/config/c_purposes/"+id
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
                        var mf = String()
                        if jsonKbira["data"]["label"].string != nil{
                        mf = jsonKbira["data"]["label"].string!
                        }else{
                            mf = "Inconnu"
                        }
                        DispatchQueue.main.async {
                            completion(mf)
                        }
                    }
                }
        }
    }
    
    func getConsultations(completion: @escaping ([CalendarConsultation]) -> Void) {
        let lien = URL(string: AppDelegate.url + "/consultations")
        let headers: HTTPHeaders = [
            "Content-Type":"application/json"
        ]
        Alamofire.request(lien!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
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
                        
                        var arrayConsul: [CalendarConsultation] = Array()
                        for item in json["data"]{
                            var motif: String = ""
                            if item.1["consultationPurpose"].string != nil{
                             motif = item.1["consultationPurpose"].string!
                                print("chwaya")
                                print(motif)
                            }else {
                                 motif = "Inconnu"
                            }
                            let date = item.1["date"].string!
                            let patientFullName = item.1["patient"]["firstName"].string! + " " + item.1["patient"]["lastName"].string!
                            var tDate = String()
                            var tTime = String()
                            tDate = date.substring(with: 0..<10)
                            tTime = date.substring(with: 11..<19)
                            
                            arrayConsul.append(CalendarConsultation(patientFullName: patientFullName, date: tDate, time: tTime, motif: motif))
                            
                        }
                        
                        DispatchQueue.main.async {
                            completion(arrayConsul)
                        }
                    }
                }
        }
    }
    
    // MARK: - JBDatePickerViewDelegate
    
    func didSelectDay(_ dayView: JBDatePickerDayView) {
        self.rightPatients.removeAll()
        self.tableView.reloadData()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        
        let dateFormatterGet2 = DateFormatter()
        dateFormatterGet2.dateFormat = "dd/MM/yyyy"
        dateConsul.isHidden = false
        dateConsul.text = "Vos consultations du "+dateFormatterGet2.string(from: dayView.date!)
        
        let myString = dateFormatterPrint.string(from: dayView.date!)
        print(myString)
        
        for item in self.consultations {
            let date: NSDate? = dateFormatterGet.date(from: item.date)! as NSDate
            let dd = dateFormatterPrint.string(from: date! as Date)
            if (dd == myString) {
                print(item.patientFullName)
                self.rightPatients.append(item)
                self.tableView.reloadData()
            }
        }
        
    }
    
    func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
        monthLabel.text = monthView.monthDescription
        
    }
    
    //custom first day of week
    var firstWeekDay: JBWeekDay {
        return .wednesday
    }
    
    //custom font for weekdaysView
    var fontForWeekDaysViewText: JBFont {
        
        return JBFont(name: "AvenirNext-MediumItalic", size: .medium)
    }
    
    //custom font for dayLabel
    var fontForDayLabel: JBFont {
        return JBFont(name: "Avenir", size: .medium)
    }
    
    //custom colors
    var colorForWeekDaysViewBackground: UIColor {
        return UIColor(red: 136/255.0, green: 14/255.0, blue: 79/255.0, alpha: 1.0)
    }
    
    var colorForSelectionCircleForOtherDate: UIColor {
        return UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    }
    
    var colorForSelectionCircleForToday: UIColor {
        return UIColor(red: 191.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
    }
    var colorForDayLabelInMonth: UIColor {
        return UIColor.white
    }
    var colorForSelelectedDayLabel: UIColor { return UIColor.black }

    //only show the dates of the current month
    var shouldShowMonthOutDates: Bool {
        return false
    }
    
    //custom weekdays view height
    var weekDaysViewHeightRatio: CGFloat {
        return 0.15
    }
    
    //custom selection shape
    var selectionShape: JBSelectionShape {
        return .roundedRect
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
