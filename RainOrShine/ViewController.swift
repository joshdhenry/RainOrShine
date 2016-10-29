//
//  ViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftyJSON

import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
 
    var keys: NSDictionary = NSDictionary()
    let locationManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient?
    
    var searchController: UISearchController?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?
    
    var locationAPIService: LocationAPIService?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        placesClient = GMSPlacesClient.shared()
        
        getAPIKeys()

        locationAPIService = LocationAPIService()
        
        displayLocationSearchBar()
    }
    
    
    func getAPIKeys() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        keys = NSDictionary(contentsOfFile: path)!
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
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let screenWidth = UIScreen.main.bounds.width
        
        let subView = UIView(frame: CGRect(x: 0, y: 20, width: screenWidth, height: 45))
        
        subView.addSubview((searchController?.searchBar)!)
        self.view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        //searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    
    
    //If the GPS button is tapped, show weather for user's current location
    @IBAction func buttonTapped(_ sender: AnyObject) {        
        locationAPIService?.getCurrentLocation() { (locationFound) -> () in            
            if (locationFound == true) {
                let place = self.locationAPIService?.currentPlace
                
                self.addressLabel.text = place?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
                
                print("THIS ATTRIBUTION MUST BE SHOWN TO GIVE CREDIT FOR THE PIC\(place?.attributions)")
                //https://developers.google.com/places/ios-api/attributions
                //LINKS IN ATTRIBUTIONS MUST BE TAPPABLE
                
                print("coords \(place?.coordinate)")
                let cityQueryString = self.getCityQueryString(place: place)
                
                //Get the place ID of the general area so that we can grab an image of the city
                let placeIDOfGeneralArea: String? = self.getPlaceIDOfGeneralArea(cityQuery: cityQueryString)
                
                if (placeIDOfGeneralArea != nil) {
                    self.loadFirstPhotoForPlace(placeID: placeIDOfGeneralArea!)
                }
                else {
                    print("Not loading a photo since place ID of general area was nil...")
                    self.resetLocationImageView()
                }
            }
        }
    }
    
    
    //This method builds a string of the general locality of the place
    func getCityQueryString(place: GMSPlace?) -> String {
        var queryString: String = String()
        
        for addressComponent in (place?.addressComponents)! {
            print(addressComponent.type)
            print(addressComponent.name)
            
            switch (addressComponent.type) {
                //case "sublocality_level_1":
            //    queryString += thisType.name
            case "locality":
                queryString += addressComponent.name
            case "administrative_area_level_1":
                queryString += "+" + addressComponent.name
            case "country":
                queryString += "+" + addressComponent.name
            default:
                break
            }
        }
        
        //Replace any spaces in the URL with "+"
        queryString = queryString.replacingOccurrences(of: " ", with: "+")
        
        return queryString
    }
  
    
    //This method takes a general area string (such as "Atlanta, Georgia, United States") and gets a place ID for that area
    func getPlaceIDOfGeneralArea(cityQuery: String) -> String? {
        var placeID: String?
        var completionHandlerCodeComplete: Bool = false
        
        print(cityQuery)
        
        let placeTextSearchURL: String = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" + cityQuery + "&key=" + (keys["GooglePlacesAPIKeyWeb"] as! String)

        
        print("placeTextSearchURL is \(placeTextSearchURL)")
        
        let session = URLSession.shared
        /*guard let url = URL(string: placeTextSearchURL) else {
            print("OH NOOOO")
            return nil
        }*/
        //I NEED TO CHECK HERE THAT THERE IS NO ERROR.
        //PREVIOUSLY IT CRASHED IF THERE WERE SPACES IN THE URL.  I NEED TO FIND OUT HOW ELSE IT COULD CRASH
        let url = URL(string: placeTextSearchURL)!
        
        // Make call. Handle it in a completion handler.
        session.dataTask(with: url as URL, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            //Ensure the  response isn't an error
            guard let thisURLResponse = response as? HTTPURLResponse,
                thisURLResponse.statusCode == 200 else {
                    print("Not a 200 (successful) response")
                    return
            }
            let json = JSON(data: data!)
            placeID = json["results"][0]["place_id"].string
            
            completionHandlerCodeComplete = true
        }).resume()
        
        while (completionHandlerCodeComplete == false) {
            print("Waiting on the photo reference to retrieve...")
        }
        return placeID
    }
    
    
    //Retrieve photo metadata for place
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                print("Error loading photo from Google API: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
                else {
                    print("No photos found. Resetting image view to blank...")
                    self.resetLocationImageView()
                }
            }
        }
    }
    
    
    //Retrieve image based on place metadata
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, constrainedTo: locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (photo, error) -> Void in
            if let error = error {
                print("Error loading image for metadata: \(error.localizedDescription)")
            } else {
                self.locationImageView.image = photo
                //self.attributionTextView.attributedText = photoMetadata.attributions;
            }
        }
    }
    
    
    func resetLocationImageView() {
        self.locationImageView.image = nil
    }
}
