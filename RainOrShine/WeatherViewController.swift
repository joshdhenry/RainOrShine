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

class WeatherViewController: UIViewController , CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var currentWeatherView: WeatherView!
    @IBOutlet weak var locationView: LocationView!
    private var locationSearchView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoDetailView: PhotoDetailView!
    
    let locationManager = CLLocationManager()
    
    internal var searchController: UISearchController?
    private var resultsViewController: GMSAutocompleteResultsViewController?
    
    var screenWidthAndHeight: CGSize = CGSize(width: 0, height: 0)
    
    
    var viewModel: WeatherViewModel? {
        didSet {            
            viewModel?.currentForecast.observe { [unowned self] in
                if ($0 != nil) {
                    //TURN THIS INTO A METHOD.  MAYBE MAKE A TEMPERATURE CLASS/ STRUCT?
                    let unformattedTemperature = $0?.currently?.temperature
                    var formattedTemperature: String = String()
                    
                    if (unformattedTemperature != nil) {
                        formattedTemperature = String(format: "%.0f", unformattedTemperature!)
                    }
                    
                    formattedTemperature += "°"
                    
                    let summaryString = $0?.currently?.summary

                    DispatchQueue.main.async {
                        self.currentWeatherView.temperatureLabel.text = formattedTemperature
                        self.currentWeatherView.summaryLabel.text = summaryString
                        self.currentWeatherView.isHidden = false
                        
                        self.currentWeatherView.fadeIn()
                    }
                }
                else {
                    self.currentWeatherView.isHidden = true
                }
            }
            
            viewModel?.currentPlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.locationView.isHidden = false
                    self.locationView.locationLabel.text = $0?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
                    
                    self.locationView.fadeIn()
                    
                    self.photoDetailView.isHidden = false
                    self.photoDetailView.fadeIn()
                }
                else {
                    self.locationView.isHidden = true
                    self.photoDetailView.isHidden = true
                }
            }
            
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                guard let currentPlace: Place = LocationAPIService.currentPlace else {
                    //I DON'T KNOW WHY BUT MY TEST DOES NOT LIKE THIS, YET IN PRODUCTION IT WORKS FINE.
                    //Place is nil.  App must be just starting
                    self.locationImageView.image = nil
                
                    self.photoDetailView.photoPageControl.isHidden = true
                    self.photoDetailView.photoPageControl.currentPage = 0
                    
                    self.photoDetailView.photoAttributionLabel.isHidden = true
                    
                    return
                }
                
                if (currentPlace.generalLocalePhotoArray.count > 0) {
                    self.locationImageView.image = currentPlace.generalLocalePhotoArray[($0)!]
                    
                    self.photoDetailView.photoPageControl.isHidden = false
                    self.photoDetailView.photoPageControl.currentPage = $0!
                    
                    guard let photoMetaData: GMSPlacePhotoMetadata = currentPlace.generalLocalePhotoMetaDataArray[$0!] else {
                        self.photoDetailView.photoAttributionLabel.isHidden = true
                        return
                    }
                    
                    let attributionPrefixAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 12)]
                    let attributionPrefixString: NSMutableAttributedString = NSMutableAttributedString(string: "Photo by ", attributes: attributionPrefixAttributes)
                    let completeAttributionString = NSMutableAttributedString()
                    
                    completeAttributionString.append(attributionPrefixString)
                    completeAttributionString.append(photoMetaData.attributions!)
                    
                    self.photoDetailView.photoAttributionLabel.attributedText = completeAttributionString
                    self.photoDetailView.photoAttributionLabel.isHidden = false
                }
                else {
                    //No images
                    self.locationImageView.image = nil
                    
                    self.photoDetailView.photoPageControl.isHidden = true
                    self.photoDetailView.photoPageControl.currentPage = 0
                    self.photoDetailView.photoAttributionLabel.isHidden = true
                }
            }
            /*
            viewModel?.blur.observe { [unowned self] in
                //THIS IS WHERE I WOULD CHANGE THE BLUR
                //THE ONLY WAY TO CHANGE THE BLUR IS TO REMOVE THE OLD UIVISUALEFFECTVIEW AND REPLACE IT WITH A NEW ONE WITH THE UPDATED UIVISUALEFECT
                //self.locationView.view
                print("UNDER CONSTRUCTION...\(($0!))")
            }*/
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidthAndHeight = getScreenWidthAndHeight()
        setAllAPIKeys()
        configureLocationManager()
        createObservers()
        createLocationSearchControllers()
        
        WeatherAPIService.setWeatherClient()

        viewModel = WeatherViewModel()
        
        //viewModel?.updateBlurStyle(blurStyle: .dark)
        
    }
    
    
    // Hide the navigation bar on the this view controller
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Redraw the location search bar when coming back to this view controller from other view controllers.  User could have changed orientations since leaving this controller.
        resizeLocationSearchView()
    }
    
    
    // Show the navigation bar on other view controllers
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        destroyRotationObserver()
    }
    
    
    //Set all API keys for all APIs being used
    private func setAllAPIKeys() {
        LocationAPIService.setAPIKeys()
        WeatherAPIService.setAPIKeys()
    }
    
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    private func createObservers() {
        createRotationObserver()
        createGestureRecognizers()
        createBatteryStateObserver()
    }
    
    
    //Begin monitoring charging state.
    private func createBatteryStateObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: Notification.Name.UIDeviceBatteryStateDidChange, object: nil)
    }
    
    
    //Begin monitoring device orientation.  If rotated, call deviceDidRotate()
    func createRotationObserver() {
        //print("In func createRotationObserver...")
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidRotate), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    
    //Create gesture recognizers for swiping left and right through location photos
    private func createGestureRecognizers() {
        //print("In func createGestureRecognizers...")
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    
    //If the battery state changes, turn on or off the screen lock accordingly
    dynamic func batteryStateDidChange(notification: NSNotification){
        // The stage did change: plugged, unplugged, full charge...
        if (UIDevice.current.batteryState == UIDeviceBatteryState.charging) {
            //Turn off the screen lock
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else if (UIDevice.current.batteryState == UIDeviceBatteryState.unplugged) {
            //Turn on the screen lock
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    
    //If the device is rotated, display the location search bar appropriately
    dynamic func deviceDidRotate(notification: NSNotification) {
        print("In func deviceDidRotate()...")
        
        //print(UIApplication.shared.statusBarOrientation.isLandscape)
        //print(UIApplication.shared.statusBarOrientation.isPortrait)
        //print(UIApplication.shared.isStatusBarHidden)

        if (Rotation.allowed) {
            resizeLocationSearchView()
        }
    }
    
    
    //If the user is searching, disable rotation until finished
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing...")
        
        Rotation.allowed = false
    }
    
    
    //If the user is done searching, re-enable screen rotation
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing...")
        
        Rotation.allowed = true
    }
    
    
    //If the user swipes right or left, adjust viewmodel.updatePlaceImageIndex accordingly
    dynamic func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        //print("In func respondToSwipeGesture")
        
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {return}
        
        //If there are photos to swipe through, then allow swiping
        if ((LocationAPIService.currentPlace?.generalLocalePhotoArray.count)! > 0) {
            
            let currentPage = advancePage(direction: swipeGesture.direction, currentPageNumber: self.photoDetailView.photoPageControl.currentPage, totalNumberOfPages: self.photoDetailView.photoPageControl.numberOfPages)
            
            viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPage)
        }
    }
    
    
    //Get the width and height of the UI Screen
    private func getScreenWidthAndHeight() -> CGSize {
        var screenWidth: CGFloat = 0.0
        var screenHeight: CGFloat = 0.0
        
        if (UIScreen.main.bounds.width < UIScreen.main.bounds.height) {
            screenWidth = UIScreen.main.bounds.width
            screenHeight = UIScreen.main.bounds.height
        }
        else {
            screenWidth = UIScreen.main.bounds.height
            screenHeight = UIScreen.main.bounds.width
        }
        
        //print("screenWidth is \(screenWidth)")
        //print("screenHeight is \(screenHeight)")
        
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    
    //Initialize and configure the Google Places search controllers
    private func createLocationSearchControllers() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
     
        let resultsFilter: GMSAutocompleteFilter = GMSAutocompleteFilter()
        resultsFilter.type = .city
        resultsViewController?.autocompleteFilter = resultsFilter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.barTintColor = UIColor(netHex: ColorScheme.lightGray)
        searchController?.searchBar.delegate = self
        
        initializeLocationSearchView()
        
        locationSearchView.addSubview((searchController?.searchBar)!)
        
        locationSearchView.accessibilityIdentifier = "Location Search Bar"
        
        self.view.addSubview(locationSearchView)
        
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        //When UISearchController presents the results view, present it in this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    

    //Create the views necessary for searching locations
    private func initializeLocationSearchView() {
        /*if (UIApplication.shared.statusBarOrientation.isLandscape) {
         if (UIApplication.shared.isStatusBarHidden) {
         subView = UIView(frame: CGRect(x: 0, y: 0, width: screenHeight, height: 45))
         }
         else {
         subView = UIView(frame: CGRect(x: 0, y: 20, width: screenHeight, height: 45))
         }
         }
         else if (UIApplication.shared.statusBarOrientation.isPortrait) {
         subView = UIView(frame: CGRect(x: 0, y: 20, width: screenWidth, height: 45))
         }*/
        
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            // do your portrait stuff
            locationSearchView = UIView(frame: CGRect(x: 0, y: 20, width: screenWidthAndHeight.width, height: 45))
        } else {
            // do your landscape stuff
            if (UIApplication.shared.isStatusBarHidden) {
                locationSearchView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidthAndHeight.height, height: 45))
            }
            else {
                locationSearchView = UIView(frame: CGRect(x: 0, y: 20, width: screenWidthAndHeight.height, height: 45))
            }
        }
        
        searchController?.searchBar.sizeToFit()
    }
    
    
    //Resize the views necessary for location.  Determine if the device is portrait or landscape and resize the search bar accordingly.
    internal func resizeLocationSearchView() {
        /*if (UIApplication.shared.statusBarOrientation.isLandscape) {
         if (UIApplication.shared.isStatusBarHidden) {
         subView.frame = CGRect(x: 0, y: 0, width: screenHeight, height: 45)
         }
         else {
         subView.frame = CGRect(x: 0, y: 20, width: screenHeight, height: 45)
         }
         }
         else if (UIApplication.shared.statusBarOrientation.isPortrait) {
         subView.frame = CGRect(x: 0, y: 20, width: screenWidth, height: 45)
         }*/
        print("UIScreen.main.bounds.width is \(UIScreen.main.bounds.width)")
        print("UIScreen.main.bounds.height is \(UIScreen.main.bounds.height)")
        print(self.view.frame.size)
        
        print("screenWidthAndHeight.width is \(screenWidthAndHeight.width)")
        print("screenWidthAndHeight.height is \(screenWidthAndHeight.height)")
        
        
        //THIS < OR > IN THIS LINE NEEDS TO BE DIFFERENT DEPENDING ON THE DEVICE.  FOR SURE, IPHONE 6, IPHONE 6 PLUS NEEDS TO BE >.  IPAD AIR 2 NEEDS TO BE <
        //SO WHAT I REALLY NEED TO DO TOMORROW IS JUST TEST ON ALL SCREEN TYPES AND DO DIFFERENT < OR > DEPENDING ON THE DEVICE IDIOM.
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            // do your portrait stuff
            print("Switching to portrait...")
            locationSearchView.frame = CGRect(x: 0, y: 20, width: screenWidthAndHeight.width, height: 45)
            //print(locationSearchView.frame.width)
            
            searchController?.view.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.width, height: screenWidthAndHeight.height)
        } else {    // in landscape
            // do your landscape stuff
            print("Switching to landscape...")
            
            if (UIApplication.shared.isStatusBarHidden) {
                locationSearchView.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.height, height: 45)
            }
            else {
                locationSearchView.frame = CGRect(x: 0, y: 20, width: screenWidthAndHeight.height, height: 45)
            }
        }
        
        /*print(locationSearchView.frame)
        print(searchController?.view.frame)
        print(searchController?.searchBar.frame)*/
        
        searchController?.searchBar.sizeToFit()
        
        /*print(locationSearchView.frame)
        print(searchController?.view.frame)
        print(searchController?.searchBar.frame)*/
    }
    
    
    //Change the place that will be displayed in this view controller (including new place photos and weather forecast)
    internal func changePlaceShown() {
        //print("In func changePlaceShown...")
        
        var photosComplete: Bool = false
        var weatherComplete: Bool = false
        
        //Reset some values
        self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: nil)
        LocationAPIService.currentPlace?.generalLocalePhotoArray.removeAll(keepingCapacity: false)
        LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray.removeAll(keepingCapacity: false)
        
        
        activityIndicator.startAnimating()
        
        //Run both functions.  If both are complete, stop the activity indicator
        displayNewPlacePhotos() { (isComplete) -> () in
            if (isComplete == true) {
                photosComplete = true
                if (weatherComplete == true) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    
                }
            }
        }
        displayNewPlaceWeather() { (isComplete) -> () in
            if (isComplete == true) {
                weatherComplete = true
                if (photosComplete == true) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    
    //Display new place photos when a new place has been chosen
    private func displayNewPlacePhotos(completion: @escaping (_ result: Bool) ->()) {
        //Get the photos of the general locale
        LocationAPIService.setPhotoOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (isImageSet) -> () in
            //print("IMAGE SET == \(imageSet)")
            if (isImageSet == true) {
                //Reset image page control
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: 0)
                
                //Adjust the page control according to the newly loaded place (if the place is not nil)
                guard let currentPlace = LocationAPIService.currentPlace else {return}
                
                if (currentPlace.generalLocalePhotoArray.count == 0) {
                    
                    //self.imagePageControl.isHidden = true
                    //self.imagePageControl.numberOfPages = 0
                    
                    self.photoDetailView.photoPageControl.isHidden = true
                    self.photoDetailView.photoPageControl.numberOfPages = 0
                }
                else {
                    //self.imagePageControl.numberOfPages = currentPlace.generalLocalePhotoArray.count
                    //self.imagePageControl.isHidden = false
                    
                    
                    self.photoDetailView.photoPageControl.numberOfPages = currentPlace.generalLocalePhotoArray.count
                    self.photoDetailView.photoPageControl.isHidden = false
                }
                
                completion(true)
            }
        }
    }
    
    
    //Display weather info when a new place has been chosen
    private func displayNewPlaceWeather(completion: @escaping (_ result: Bool) ->()) {
        //Get the weather forecast
        guard let currentPlace = LocationAPIService.currentPlace else {return}
        guard let currentGMSPlace = currentPlace.gmsPlace else {return}
        
        WeatherAPIService.setCurrentWeatherForecast(latitude: currentGMSPlace.coordinate.latitude, longitude: currentGMSPlace.coordinate.longitude) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                self.viewModel?.updateForecast(newForecast: WeatherAPIService.currentWeatherForecast)
                
                completion(true)
            }
        }
    }
    

    //Advance forwards or backwards through page numbers, accounting for total number of pages
    private func advancePage(direction: UISwipeGestureRecognizerDirection, currentPageNumber: Int, totalNumberOfPages: Int) -> Int {
        var newPageNumber: Int = currentPageNumber
        
        if (direction == UISwipeGestureRecognizerDirection.left) {
            if (currentPageNumber < totalNumberOfPages - 1) {
                newPageNumber += 1
            }
        }
        else {
            if (currentPageNumber > 0) {
                newPageNumber -= 1
            }
        }
        return newPageNumber
    }
    
    
    //If the GPS button is tapped, show weather for user's current location
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        //GPS is allowed.  Turn on GPS locator and continue seeking the weather for current location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        }
        //GPS is off.  Alert the user and return out of this function.
        else {
            let gpsAlert = UIAlertController(title: "GPS Not Enabled", message: "GPS is not enabled for this app.  Go to Settings -> Privacy -> Location Services and allow the app to utilize GPS.", preferredStyle: .alert)
            gpsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(gpsAlert, animated: true, completion: nil)
            
            return
        }
        
        makeSubViewsInvisible()
        
        LocationAPIService.setCurrentLocationPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound == true) {
                self.viewModel?.updatePlace(newPlace: locationPlace)

                LocationAPIService.currentPlace = locationPlace
                
                self.changePlaceShown()
                
                //Once the data is retrieved, turn off the GPS
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    
    //Make all subviews' alpha 0
    internal func makeSubViewsInvisible() {
        currentWeatherView.alpha = 0
        locationView.alpha = 0
        photoDetailView.alpha = 0
    }
    
    
    //DO THIS FOR OTHER OBSERVERS IF NEEDED
    //End monitoring device orientation
    private func destroyRotationObserver() {
        NotificationCenter.default.removeObserver(self)
        if UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
}
