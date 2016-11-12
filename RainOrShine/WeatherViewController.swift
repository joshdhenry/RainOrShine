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
import ForecastIO

class WeatherViewController: UIViewController , CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var currentWeatherView: WeatherView!
    @IBOutlet weak var locationView: LocationView!
    public var locationSearchView: LocationSearchView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoDetailView: PhotoDetailView!
    @IBOutlet weak var futureWeatherView: FutureWeatherView!
    
    let locationManager = CLLocationManager()
    var screenWidthAndHeight: CGSize = CGSize(width: 0, height: 0)
    var isStatusBarVisible: Bool = true
    
    override var prefersStatusBarHidden: Bool {
        return !isStatusBarVisible
    }

    
    var viewModel: WeatherViewModel? {
        didSet {
            //unowned is fine here because this view controller is the owner of view model so view model will not outlive view controller.
            viewModel?.currentForecast.observe { [unowned self] in
                guard let forecast: Forecast = $0 else {
                    self.currentWeatherView.isHidden = true
                    return
                }
                guard let currently = forecast.currently else {return}
                
                var futureDaySubViewsArray: [UIView] = [UIView]()
                
                if (!WeatherAPIService.forecastDayDataPointArray.isEmpty) {
                    for thisView in self.futureWeatherView.allSubViews {
                        if let futureDayView = thisView as? FutureWeatherDayView {
                            futureDaySubViewsArray.append(futureDayView)
                        }
                    }
                    futureDaySubViewsArray.sort(by: { $0.center.x < $1.center.x })
                }

                //Update the UI on the main thread
                DispatchQueue.main.async {
                    self.currentWeatherView.temperatureLabel.text = currently.temperature?.getFormattedTemperatureString() ?? ""
                    self.currentWeatherView.summaryLabel.text = currently.summary
                    self.currentWeatherView.weatherConditionView.setType =  currently.icon?.getSkycon() ?? Skycons.partlyCloudyDay
                    self.currentWeatherView.weatherConditionView.play()
                    self.currentWeatherView.isHidden = false
                    self.currentWeatherView.fadeIn()
                    
                    //Populate five day forecast from the sorted array
                    for futureDaySubViewIndex in 0..<futureDaySubViewsArray.count {
                        if let futureDayView = futureDaySubViewsArray[futureDaySubViewIndex] as? FutureWeatherDayView {
                            futureDayView.summaryLabel.text = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].summary
                            futureDayView.weatherConditionView.setType = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].icon?.getSkycon() ?? Skycons.partlyCloudyDay
                            futureDayView.weatherConditionView.play()
                            
                            futureDayView.dayLabel.text = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].time.toAbbreviatedDayString()
                            
                            var temperatureLabelText: String = String()
                            
                            //MAKE A DICTIONARY WITH THE MIN AND MAX.  CREATE AN EXTENSION OF A DICTIONARY THAT WILL BE CALLED getFormattedTemperatureRANGEString and implement it here
                            let minTemperatureText = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].temperatureMin?.getFormattedTemperatureString() ?? ""
                            let maxTemperatureText = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].temperatureMax?.getFormattedTemperatureString() ?? ""
                            
                            temperatureLabelText = minTemperatureText + "/" + maxTemperatureText
                            
                            futureDayView.temperatureLabel.text = temperatureLabelText
                        }
                    }
                }
            }
            
            viewModel?.currentPlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.locationView.isHidden = false
                    self.locationView.fadeIn()
                    
                    self.photoDetailView.isHidden = false
                    self.photoDetailView.fadeIn()
                }
                else {
                    self.locationView.isHidden = true
                    self.photoDetailView.isHidden = true
                }
            }
            
            viewModel?.currentGeneralLocalePlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.locationView.locationLabel.text = $0?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
                }
                else {
                    self.locationView.locationLabel.text = ""
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
                    
                    //This can be tested by using Oirschot, Netherlands as the location.  One photo does not have an attribution.
                    guard let photoAttributions = photoMetaData.attributions else {
                        self.photoDetailView.photoAttributionLabel.text = ""
                        self.photoDetailView.photoAttributionLabel.isHidden = true
                        return
                    }
                    
                    let attributionPrefixAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 12)]
                    let attributionPrefixString: NSMutableAttributedString = NSMutableAttributedString(string: "Photo by ", attributes: attributionPrefixAttributes)
                    let completeAttributionString = NSMutableAttributedString()
                    
                    completeAttributionString.append(attributionPrefixString)
                    completeAttributionString.append(photoAttributions)
                    
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
        }
    }
    
    
    //Initialize values for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MAKE THIS A COMPUTED PROPERTY
        screenWidthAndHeight = getScreenWidthAndHeight()
        
        setAllAPIKeys()
        configureLocationManager()
        WeatherAPIService.setWeatherClient()
        createObservers()
        createLocationSearchElements()
        viewModel = WeatherViewModel()
        
        setNightStandMode()
    }
    
    
    // Hide the navigation bar on the this view controller
    override func viewWillAppear(_ animated: Bool) {
        print("In func viewWillAppear...")
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Redraw the location search bar when coming back to this view controller from other view controllers.  User could have changed orientations since leaving this controller.
        resizeLocationSearchView(orientationAfterRotation: UIDevice.current.orientation)
    }
    
    
    // Show the navigation bar on other view controllers
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    //If the view's orientation changed, make sure that the location search bar is correctly aligned
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if (Rotation.allowed) {
            if (UIDevice.current.orientation.isLandscape ||
                UIDevice.current.orientation.isPortrait) {
                resizeLocationSearchView(orientationAfterRotation: UIDevice.current.orientation)
            }
        }
    }
    
    
    //Set all API keys for all APIs being used
    private func setAllAPIKeys() {
        LocationAPIService.setAPIKeys()
        WeatherAPIService.setAPIKeys()
    }
    
    
    //Set and configure the location manager
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //This will reduce battery usage and processing time
        locationManager.desiredAccuracy  = kCLLocationAccuracyKilometer
    }
    
    
    //Create and start all observers
    private func createObservers() {
        createTimeObserver()
        createGestureRecognizers()
        createBatteryStateObserver()
    }
    
    
    //Create a time observer to run every 60 seconds to refresh the weather forecast
    private func createTimeObserver() {
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.oneMinuteElapsed), userInfo: nil, repeats: true)
    }
    
    
    //Create gesture recognizers for swiping left and right through location photos
    private func createGestureRecognizers() {
        //print("In func createGestureRecognizers...")        
        self.view.addGestureRecognizer(setTapRecognizer())
        locationImageView.addGestureRecognizer(setTapRecognizer())
        currentWeatherView.addGestureRecognizer(setTapRecognizer())
        locationView.addGestureRecognizer(setTapRecognizer())
        currentWeatherView.addGestureRecognizer(setTapRecognizer())
        futureWeatherView.addGestureRecognizer(setTapRecognizer())
        photoDetailView.addGestureRecognizer(setTapRecognizer())
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    
    private func setTapRecognizer() -> UITapGestureRecognizer {
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.viewTapped (_:)))
        return tapRecognizer
    }
    
    
    //Begin monitoring charging state.
    private func createBatteryStateObserver() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: Notification.Name.UIDeviceBatteryStateDidChange, object: nil)
    }
    
    
    //If the battery state changes, turn on or off the screen lock accordingly
    dynamic func batteryStateDidChange(notification: NSNotification){
        setNightStandMode()
    }
    
    
    func oneMinuteElapsed() {
        //print("In func oneMinuteElapsed...")
        
        self.activityIndicator.startAnimating()
        
        loadNewPlaceWeather() { (isComplete) -> () in
            if (isComplete == true) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    
    private func setNightStandMode() {
        print("In setNightStand Mode...")

        if (UIDevice.current.batteryState == UIDeviceBatteryState.charging) {
            //Turn off the screen lock
            UIApplication.shared.isIdleTimerDisabled = true
            
            print("Charging...")
        }
        else if (UIDevice.current.batteryState == UIDeviceBatteryState.unplugged) {
            //Turn on the screen lock
            UIApplication.shared.isIdleTimerDisabled = false
            
            print("Unplugged")
        }
    }
    
    
    //If the user is searching, disable rotation until finished
    internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing...")
        
        Rotation.allowed = false
    }
    
    
    //If the user is done searching, re-enable screen rotation
    internal func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing...")
        
        Rotation.allowed = true
    }
    
    
    internal func viewTapped(_ sender:UITapGestureRecognizer) {
        if (futureWeatherView.alpha == 0) {
            futureWeatherView.fadeIn(withDuration: 0.75, finalAlpha: 0.8)
        }
        else {
            futureWeatherView.fadeOut()
        }
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
    
    
    //Initialize and configure the Google Places search controllers
    private func createLocationSearchElements() {
        locationSearchView = LocationSearchView(withOrientation: UIDevice.current.orientation, screenWidthAndHeight: screenWidthAndHeight)
        
        locationSearchView.resultsViewController?.delegate = self
        locationSearchView.searchController?.searchBar.delegate = self

        self.view.addSubview(locationSearchView)
        
        locationSearchView.searchController?.searchBar.sizeToFit()
        locationSearchView.searchController?.hidesNavigationBarDuringPresentation = false
        
        //When UISearchController presents the results view, present it in this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    
    
    //Get the width and height of the UI Screen
    private func getScreenWidthAndHeight() -> CGSize {
        var widthAndHeight = (width: CGFloat(), height: CGFloat())
        
        if (UIScreen.main.bounds.width < UIScreen.main.bounds.height) {
            widthAndHeight = (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        }
        else {
            widthAndHeight = (UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        }
        let sizeToReturn = CGSize(width: widthAndHeight.width, height: widthAndHeight.height)
        
        return sizeToReturn
    }
    
    
    //CAN I MAKE THIS A METHOD OF LOCATIONSEARCHVIEW CLASS?????
    internal func resizeLocationSearchView(orientationAfterRotation: UIDeviceOrientation) {
        //print("In resizeLocationSearchView...")
        
        if orientationAfterRotation.isPortrait {
            print("Switching to portrait...")
            
            showStatusBar(enabled: true)
            
            locationSearchView.frame = CGRect(x: 0, y: 20, width: screenWidthAndHeight.width, height: 45)
            locationSearchView.searchController?.view.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.width, height: screenWidthAndHeight.height)
        }
        else if orientationAfterRotation.isLandscape {
            print("Switching to landscape...")
            
            showStatusBar(enabled: false)
            
            locationSearchView.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.height, height: 45)
        }
        locationSearchView.searchController?.searchBar.sizeToFit()
    }
    
    
    func showStatusBar(enabled: Bool) {
        isStatusBarVisible = enabled
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    //Make all subviews' alpha 0
    internal func makeSubViewsInvisible() {
        currentWeatherView.alpha = 0
        locationView.alpha = 0
        photoDetailView.alpha = 0
        futureWeatherView.alpha = 0
    }
   
    
    //If the GPS button is tapped, show weather for user's current location
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        
        //If GPS is turned off, show an error message
        if (!CLLocationManager.locationServicesEnabled()) {
            let gpsAlert = UIAlertController(title: "GPS Not Enabled", message: "Location services are not enabled on this device.  Go to Settings -> Privacy -> Location Services and enable location services.", preferredStyle: .alert)
            gpsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(gpsAlert, animated: true, completion: nil)
            
            return
        }
        else if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            let gpsAlert = UIAlertController(title: "GPS Not Enabled", message: "GPS is not enabled for this app.  Go to Settings -> Privacy -> Location Services and allow the app to utilize GPS.", preferredStyle: .alert)
            gpsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(gpsAlert, animated: true, completion: nil)
            
            return
        }
        
        //GPS is allowed.  Continue seeking the weather for current location
        makeSubViewsInvisible()
        
        LocationAPIService.setCurrentExactPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound) {
                self.viewModel?.updatePlace(newPlace: locationPlace)
                
                LocationAPIService.currentPlace = locationPlace
                
                //Set the general locale of the place (better for pictures and displaying user's location than exact addresses)
                LocationAPIService.setGeneralLocalePlace() { (isGeneralLocaleFound, generalLocalePlace) -> () in
                    if (isGeneralLocaleFound) {
                        
                        self.viewModel?.updateGeneralLocalePlace(newPlace: generalLocalePlace)
                        
                        LocationAPIService.generalLocalePlace = generalLocalePlace
                        
                        self.changePlaceShown()
                    }
                }
            }
        }
    }
    
    
    //Change the place that will be displayed in this view controller (including new place photos and weather forecast)
    internal func changePlaceShown() {
        //print("In func changePlaceShown...")
        
        print("PLACE IDS")
        print(LocationAPIService.currentPlace?.gmsPlace?.placeID)
        print(LocationAPIService.generalLocalePlace?.gmsPlace?.placeID)
        
        print(LocationAPIService.currentPlace?.gmsPlace?.formattedAddress)
        print(LocationAPIService.generalLocalePlace?.gmsPlace?.formattedAddress)

        
        var changePlaceCompletionFlags = (photosComplete: false, weatherComplete: false)
        
        //Reset some values
        self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: nil)
        LocationAPIService.currentPlace?.generalLocalePhotoArray.removeAll(keepingCapacity: false)
        LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray.removeAll(keepingCapacity: false)
        
        WeatherAPIService.forecastDayDataPointArray.removeAll(keepingCapacity: false)
        
        //Run both functions.  If both are complete, stop the activity indicator
        loadNewPlacePhotos() { (isComplete) -> () in
            if (isComplete == true) {
                changePlaceCompletionFlags.photosComplete = true
                if (changePlaceCompletionFlags.weatherComplete == true) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        loadNewPlaceWeather() { (isComplete) -> () in
            if (isComplete == true) {
                changePlaceCompletionFlags.weatherComplete = true
                if (changePlaceCompletionFlags.photosComplete == true) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    
    //Display new place photos when a new place has been chosen
    private func loadNewPlacePhotos(completion: @escaping (_ result: Bool) ->()) {
        LocationAPIService.setPhotosOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (isImageSet) -> () in
            if (isImageSet == true) {
                //Reset image page control
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: 0)
                
                //Adjust the page control according to the newly loaded place (if the place is not nil)
                guard let currentPlace = LocationAPIService.currentPlace else {return}
                
                if (currentPlace.generalLocalePhotoArray.count == 0) {
                    self.photoDetailView.photoPageControl.isHidden = true
                    self.photoDetailView.photoPageControl.numberOfPages = 0
                }
                else {
                    self.photoDetailView.photoPageControl.numberOfPages = currentPlace.generalLocalePhotoArray.count
                    self.photoDetailView.photoPageControl.isHidden = false
                }
                completion(true)
            }
        }
    }
    
    
    //Display weather info when a new place has been chosen. Get the weather forecast.
    private func loadNewPlaceWeather(completion: @escaping (_ result: Bool) ->()) {
        guard let currentPlace = LocationAPIService.currentPlace else {return}
        guard let currentGMSPlace = currentPlace.gmsPlace else {return}
        
        WeatherAPIService.setCurrentWeatherForecast(latitude: currentGMSPlace.coordinate.latitude, longitude: currentGMSPlace.coordinate.longitude) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                self.viewModel?.updateForecast(newForecast: WeatherAPIService.currentWeatherForecast)
                
                completion(true)
            }
        }
    }
}
