//
//  ViewController.swift
//  What's The Weather
//
//  Created by Tarek Moubarak on 9/28/18.
//  Copyright © 2018 Tarek Moubarak. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var resultsLbl: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    var message: String = ""
    var countryMessage: String = ""
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.startAnimating()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        lookUpCurrentLocation { geoLoc in
            if let searchQuery = geoLoc?.country {
                if let url = URL(string: "https://www.weather-forecast.com/locations/"+searchQuery.replacingOccurrences(of: " ", with: "-")+"/forecasts/latest"){
                    let request = NSMutableURLRequest(url: url)
                    
                    let task = URLSession.shared.dataTask(with: request as URLRequest){
                        data, response, error in
                        //data, response, error These are the 3 variables we can use below
                        if let error = error {
                            print(error)
                        } else{
                            if let unwrappedData = data {
                                let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                                var stringSeparator = "phrase"
                                if let contentArray = dataString?.components(separatedBy: stringSeparator){
                                    print(contentArray)
                                    if contentArray.count > 1{
                                        stringSeparator = "</span>"
                                        let newContentArray = contentArray[1].components(separatedBy: stringSeparator)
                                        if newContentArray.count > 1{
                                            self.countryMessage = "Weather in "+searchQuery+""
                                            self.message = newContentArray[0].replacingOccurrences(of: "\">", with: "")
                                            self.message = self.message.replacingOccurrences(of: "&deg;", with: "*")
                                        }
                                    }
                                }
                            }
                            if self.message == "" {
                                self.message = "The Weather in "+searchQuery+" couldn't be found. Please try again."
                            }
                            DispatchQueue.main.sync(execute: {
                                self.activityView.stopAnimating()
                                self.resultsLbl.text = self.message
                                self.countryLbl.text = self.countryMessage
                            });
                        }
                    }
                    task.resume()
                } else{
                    self.resultsLbl.text = "The Weather in "+searchQuery+" couldn't be found. Please try again."
                }
            } else{
                self.resultsLbl.text = "Make Sure city name is correct and try again"
            }
        }
    }
    
    // WHEN USER CLICK OUTSIDE THE TEXTFIELD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // WHEN RETURN BUTTON IS PRESSED
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func searchBtn(_ sender: Any) {
        activityView.startAnimating()
        if let searchQuery = userInput.text {
            if let url = URL(string: "https://www.weather-forecast.com/locations/"+searchQuery.replacingOccurrences(of: " ", with: "-")+"/forecasts/latest"){
                let request = NSMutableURLRequest(url: url)
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){
                    data, response, error in
                    //data, response, error These are the 3 variables we can use below
                    if let error = error {
                        print(error)
                    } else{
                        if let unwrappedData = data {
                            let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                            var stringSeparator = "phrase"
                            if let contentArray = dataString?.components(separatedBy: stringSeparator){
                                print(contentArray)
                                if contentArray.count > 1{
                                    stringSeparator = "</span>"
                                    let newContentArray = contentArray[1].components(separatedBy: stringSeparator)
                                    if newContentArray.count > 1{
                                        self.countryMessage = "Weather in "+searchQuery+""
                                        self.message = newContentArray[0].replacingOccurrences(of: "\">", with: "")
                                        self.message = self.message.replacingOccurrences(of: "&deg;", with: "*")
                                    }
                                }
                            }
                        }
                        if self.message == "" {
                            self.message = "The Weather there couldn't be found. Please try again."
                        }
                        DispatchQueue.main.sync(execute: {
                            self.activityView.stopAnimating()
                            self.resultsLbl.text = self.message
                            self.countryLbl.text = self.countryMessage
                        });
                    }
                }
                task.resume()
            } else{
                self.resultsLbl.text = "The Weather there couldn't be found. Please try again."
            }
        } else{
            self.resultsLbl.text = "Make Sure city name is correct and try again"
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("\(lat),\(long)")
        } else {
            print("No coordinates")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                    // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
}
