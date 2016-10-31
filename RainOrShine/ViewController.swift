//
//  ViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var currentWeatherView: WeatherView!
 
    let locationManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient?
    
    var searchController: UISearchController?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?
    
    var locationAPIService: LocationAPIService?
    var weatherAPIService: WeatherAPIService?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        placesClient = GMSPlacesClient.shared()
        
        WeatherAPIService.setAPIKeys()
        weatherAPIService = WeatherAPIService()
        
        LocationAPIService.setAPIKeys()
        locationAPIService = LocationAPIService()
        
        displayLocationSearchBar()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization Status Changed to \(status.rawValue)")
        switch status {
        case .authorized, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    //Show the location search bar at the top of the screen
    func displayLocationSearchBar() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        let resultsFilter: GMSAutocompleteFilter = GMSAutocompleteFilter()
        resultsFilter.type = .city
        resultsViewController?.autocompleteFilter = resultsFilter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let screenWidth = UIScreen.main.bounds.width
        let subView = UIView(frame: CGRect(x: 0, y: 20, width: screenWidth, height: 45))
        subView.addSubview((searchController?.searchBar)!)
        self.view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        
        //When UISearchController presents the results view, present it in this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    
    
    //If the GPS button is tapped, show weather for user's current location
    @IBAction func buttonTapped(_ sender: AnyObject) {
        locationAPIService?.currentPlace = nil
        
        locationAPIService?.setCurrentLocationPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound == true) {
                self.changePlace(place: locationPlace)
            }
        }
    }
    
    
    //Change the place that will be displayed in this view controller
    func changePlace(place: Place?) {
        addressLabel.text = place?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
        
        locationAPIService?.setPhotoOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (imageSet) -> () in
            if (imageSet == true) {
                self.locationImageView.image = place?.firstGeneralLocalePhoto
            }
        }
    
        weatherAPIService?.getCurrentWeatherForecast(latitude: (place?.gmsPlace?.coordinate.latitude)!, longitude: (place?.gmsPlace?.coordinate.longitude)!) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                let temperatureString = NSString(format: "%.0f", (self.weatherAPIService?.currentWeatherForecast?.currently?.temperature)!)
                print("temperatureString is \(temperatureString)")
                
                //Make sure this performs on the main queue to avoid autolayout engine crashes
                DispatchQueue.main.async {
                    self.currentWeatherView.temperatureLabel.text = temperatureString as String
                }
                print("Just set the weather label...")
            }
        }
    }
}
