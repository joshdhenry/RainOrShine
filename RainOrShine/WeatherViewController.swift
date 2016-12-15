//
//  WeatherViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMobileAds
import CoreLocation

//WeatherViewController is the main screen for the entire app.
class WeatherViewController: UIViewController {
    
    // MARK: - Properties
    // MARK: Type Aliases
    typealias ScreenSize = CGSize
    
    // MARK: UI Elements
    @IBOutlet weak var locationImageView: LocationImageView!
    @IBOutlet weak var currentWeatherView: CurrentWeatherView!    
    @IBOutlet weak var locationView: LocationView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoDetailView: PhotoDetailView!
    @IBOutlet weak var futureWeatherView: FutureWeatherView!
    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var photoDetailViewBottomConstraint: NSLayoutConstraint!
    internal var locationSearchView: LocationSearchView!
    @IBOutlet weak var appLogoImageView: AppLogoImageView!
    @IBOutlet weak var currentLocationButton: UIBarButtonItem!
    
    // MARK: Constants
    internal let defaults = UserDefaults.standard
    internal let locationManager = CLLocationManager()
    internal let refreshWeatherForecastNotification = Notification.Name(rawValue:"RefreshWeatherForecast")
    internal let refreshImageWithNewDefaultPhotosSettingsNotification = Notification.Name(rawValue: "RefreshImageWithNewDefaultPhotosSettings")

    // MARK: Variables
    override var prefersStatusBarHidden: Bool {
        return !isStatusBarVisible
    }
    internal var isStatusBarVisible: Bool = true
    internal var weatherAPIService: WeatherAPIService = WeatherAPIService()
    internal var locationAPIService: LocationAPIService = LocationAPIService()
    internal var currentSettings = Settings()
    internal var updateWeatherTimer: Timer = Timer()
    internal var changePhotoTimer: Timer = Timer()
    internal var validGPSConsecutiveSignalsReceived: Int = 0
    internal var wasPreviouslyShowingAds: Bool = true
    
    
    // MARK: - Methods
    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAllAPIKeys()
        configureLocationManager()
        weatherAPIService.setWeatherClient()
        initializeViewModels()
        createSettingsUpdatesObservers()
        createGestureRecognizers()
        createBatteryStateObserver()
        createLocationSearchElements()
        startFindingCurrentLocation(alertsEnabled: false)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Redraw the location search bar when coming back to this view controller from other view controllers since user could have changed orientations since leaving this controller.
        resizeLocationSearchView(orientationAfterRotation: UIDevice.current.orientation)
        
        createTimeObservers()
        setNightStandMode()
        displayAds()
    }
    
    
    // Show the navigation bar on other view controllers
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        destroyTimeObservers()
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
    
    
    // MARK: Other Various Methods
    
    //Set all API keys for all APIs being used in this controller
    private func setAllAPIKeys() {
        locationAPIService.setAPIKeys()
        weatherAPIService.setAPIKeys()
    }
    
    
    //Create all the view models that will be needed for this controller and its subviews
    private func initializeViewModels() {
        currentWeatherView.viewModel = CurrentWeatherViewModel(forecast: weatherAPIService.currentWeatherForecast)
        futureWeatherView.viewModel = FutureWeatherViewModel(forecastDataPointArray: weatherAPIService.forecastDayDataPointArray, timeZoneIdentifier: "GMT")
        locationView.viewModel = LocationViewModel(place: locationAPIService.currentPlace)
        locationImageView.viewModel = LocationImageViewModel(placeImageIndex: locationAPIService.currentPlaceImageIndex, place: locationAPIService.currentPlace)
        photoDetailView.viewModel = PhotoDetailViewModel(place: locationAPIService.currentPlace, imageIndex: nil)
        appLogoImageView.viewModel = AppLogoImageViewModel(placeImageIndex: locationAPIService.currentPlaceImageIndex, place: locationAPIService.currentPlace)
    }
    
    
    //Reset view model image indices with a resetValue of nil or 0
    internal func resetViewModelImageIndices(resetValue: Int?) {
        NSLog("IN FUNC RESETVIEWMODELIMAGEINDICES...")
        self.photoDetailView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: resetValue, place: self.locationAPIService.generalLocalePlace)
        self.locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: resetValue, place: self.locationAPIService.generalLocalePlace)
        self.appLogoImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: resetValue, place: self.locationAPIService.generalLocalePlace)
    }
    
    
    //Make all subviews' alpha 0
    internal func makeSubViewsInvisible() {
        currentWeatherView.alpha = 0
        locationView.alpha = 0
        photoDetailView.alpha = 0
        futureWeatherView.alpha = 0
    }
    
    
    //The order of changing to a new location based on current GPS and displaying it goes like this
    //currentLocationButtonTapped -> startFindingCurrentLocation -> location manager didUpdateLocation -> updateLocationAPIServiceLocations -> locationAPIService.getCurrentExactPlace -> locationAPIService.setGeneralLocalePlace -> changePlaceShown -> loadNewPlacePhotos & loadNewPlaceWeather -> finishChangingPlaceShown
    
    //If the GPS button is tapped, check if the user has a net connection, then show weather for user's current location
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        NSLog("---------------------------------------------------------")
        NSLog("FINDING A NEW LOCATION...")
        startFindingCurrentLocation(alertsEnabled: true)
    }
    
    
    //If the settings button was tapped, segue to SettingsTableViewController
    @IBAction func settingsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "SegueSettings", sender: self)
    }

    
    //Create the tap recognizer to detect if the screen was tapped once, which will show/hide futureWeatherView
    private func setTapRecognizer() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector (self.viewTapped (_:)))
    }
    
    
    //If the view was tapped, fade in or out the 5 day forecast
    internal func viewTapped(_ sender:UITapGestureRecognizer) {
        if (futureWeatherView.alpha == 0) {
            futureWeatherView.fadeIn(withDuration: 0.75, finalAlpha: 0.8)
        }
        else {
            futureWeatherView.fadeOut()
        }
    }
    
    
    //Create gesture recognizers for swiping left and right through location photos
    private func createGestureRecognizers() {
        self.view.addGestureRecognizer(setTapRecognizer())
        locationImageView.addGestureRecognizer(setTapRecognizer())
        currentWeatherView.addGestureRecognizer(setTapRecognizer())
        locationView.addGestureRecognizer(setTapRecognizer())
        currentWeatherView.addGestureRecognizer(setTapRecognizer())
        futureWeatherView.addGestureRecognizer(setTapRecognizer())
        photoDetailView.addGestureRecognizer(setTapRecognizer())
        
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRightGestureRecognizer)
        
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
    }
    
    
    //If the user swipes right or left, adjust viewmodel.updatePlaceImageIndex accordingly
    dynamic func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {return}
        guard let currentGeneralLocalePlace = locationAPIService.generalLocalePlace else {return}
        
        //If photos were returned or default photos setting is turned on, allow swiping
        if (!currentGeneralLocalePlace.photoArray.isEmpty ||
            currentSettings.useDefaultPhotos == .whenNoPictures ||
            currentSettings.useDefaultPhotos == .always) {
            let currentPageNumber: Int = photoDetailView.advancePage(direction: swipeGesture.direction, place: currentGeneralLocalePlace, looping: false)
            
            locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
            appLogoImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
        }
    }
}
