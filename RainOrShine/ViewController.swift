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
 
    @IBOutlet weak var imagePageControl: UIPageControl!
    
    //@IBOutlet var imageSwipeRightGestureRecognizer: UISwipeGestureRecognizer!
    //@IBOutlet var imageSwipeLeftGestureRecognizer: UISwipeGestureRecognizer!
    
    
    let locationManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient?
    
    var searchController: UISearchController?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?
    
    
    var viewModel: WeatherViewModel? {
        didSet {            
            viewModel?.currentForecast.observe { [unowned self] in
                let unformattedTemperature = $0?.currently?.temperature
                var formattedTemperature: String = String()

                if (unformattedTemperature != nil) {
                    formattedTemperature = String(format: "%.0f", unformattedTemperature!)
                }
                
                DispatchQueue.main.async {
                    self.currentWeatherView.temperatureLabel.text = formattedTemperature
                }
            }
            
            viewModel?.currentPlace.observe { [unowned self] in
                self.addressLabel.text = $0?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        LocationAPIService.setAPIKeys()
        WeatherAPIService.setAPIKeys()
        WeatherAPIService.setWeatherClient()

        displayLocationSearchBar()
        
        viewModel = WeatherViewModel()
        
        //self.currentWeatherView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        
        /*
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = currentWeatherView.bounds
        locationImageView.addSubview(blurEffectView)*/
        
        createGestureRecognizers()
    }
    
    
    func createGestureRecognizers() {
        print("In func createGestureRecognizers...")
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }


    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        print("In func respondToSwipeGesture")
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped left")
            default:
                break
            }
        }
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
        LocationAPIService.setCurrentLocationPlace() { (isLocationFound) -> () in
            if (isLocationFound == true) {
                self.changePlace()
            }
        }
    }
    
    
    //Change the place that will be displayed in this view controller
    func changePlace() {
        print("In func changePlace...")
        
        imagePageControl.currentPage = 3
        
        /*let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = currentWeatherView.bounds
        blurEffectView.center = currentWeatherView.center
        locationImageView.addSubview(blurEffectView)*/
        
       // print("currentWeatherView.bounds is \(currentWeatherView.bounds)")
        //print(blurEffectView.bounds)
        
        LocationAPIService.setPhotoOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (imageSet) -> () in
            if (imageSet == true) {
                self.locationImageView.image = LocationAPIService.currentPlace?.firstGeneralLocalePhoto
            }
        }
        WeatherAPIService.setCurrentWeatherForecast(latitude: (LocationAPIService.currentPlace?.gmsPlace?.coordinate.latitude)!, longitude: (LocationAPIService.currentPlace?.gmsPlace?.coordinate.longitude)!) { (forecastRetrieved) -> () in
            print("forecastRetrieved...\(forecastRetrieved)")
            if (forecastRetrieved) {
                self.viewModel?.updateForecast(newForecast: WeatherAPIService.currentWeatherForecast)
            }
        }
        self.viewModel?.updatePlace(newPlace: LocationAPIService.currentPlace)
    }
}
