//
//  LocationAPIService.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/28/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import GooglePlaces
import SwiftyJSON

class LocationAPIService {
    var keys: NSDictionary = NSDictionary()

    var placesClient: GMSPlacesClient? = GMSPlacesClient.shared()
    var currentPlace: GMSPlace?
    
    var firstGeneralLocalePhotoMetaData: GMSPlacePhotoMetadata?
    var firstGeneralLocalePhoto: UIImage?

    
    init() {
        setAPIKeys()
    }
    
    
    //Load the Google Places API keys from APIKeys.plist
    func setAPIKeys() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        keys = NSDictionary(contentsOfFile: path)!
    }
    
    
    //This method gets the current location of the user and sets currentPlace
    func setCurrentLocationPlace(completion: @escaping (_ result: Bool)->()) {
        print("In function setCurrentLocationPlace...")

        var placeFindComplete: Bool = false
        
        placesClient?.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                completion(true)
                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                let place = placeLikelihoods.likelihoods.first?.place
                self.currentPlace = place
                print("Found the place. Continuing...")
                print("Set LocationAPIService.currentPlace to \(self.currentPlace?.placeID)")
                placeFindComplete = true
                completion(true)
            }
        })
        if (placeFindComplete == false) {
            completion(false)
        }
    }
    
    
    //This method finds a photo of the general locale
    func setPhotoOfGeneralLocale(size: CGSize, scale: CGFloat, completion: @escaping (_ result: Bool) ->()) {
        print("In function setPhotoOfGeneralLocale...")
        
        let generalLocaleString: String = getGeneralLocaleString()
        
        //Get the place ID of the general area so that we can grab an image of the city
        let placeIDOfGeneralLocale: String? = getPlaceIDOfGeneralLocale(generalLocaleQueryString: generalLocaleString)
        print("Just ran getPlaceIDOfGeneralLocale.  Continuing to setPhotoMetaDataForLocation...")
        if (placeIDOfGeneralLocale != nil) {
            setPhotoMetaDataForLocation(placeID: placeIDOfGeneralLocale!) { (photoMetaDataFound) -> () in
                if (photoMetaDataFound == true) {
                    self.setImageForMetadata(size: size, scale: scale) { (imageFound) -> () in
                        if (imageFound == true) {
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    }
                }
            }
        }
        else {
            print("Not loading a photo since place ID of general area was nil...")
            completion(true)
        }
    }
    
    
    //This method resets all current place variables to nil
    func resetCurrentPlace() {
        currentPlace = nil
        
        firstGeneralLocalePhotoMetaData = nil
        firstGeneralLocalePhoto = nil
    }
    
    
    //This method builds a string of the general locality of the place, which will be used to query a photo of the general locale
    func getGeneralLocaleString() -> String {
        print("In function getGeneralLocaleString... (#1)")

        var queryString: String = String()
        
        for addressComponent in (currentPlace?.addressComponents)! {
            //print(addressComponent.type)
            //print(addressComponent.name)
            
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
    
    
    //DO I NEED TO IMPLEMENT COMPLETION HANDLER INTO THIS FUNCTION?????  I don't think so since session.data task uses resume() ??????  But then again i do have that while loop at the bottom that could be done differently.
    //This method takes a general area string (such as "Atlanta, Georgia, United States") and gets a place ID for that area
    func getPlaceIDOfGeneralLocale(generalLocaleQueryString: String) -> String? {
        print("In function getPlaceIDOfGeneralLocale...(#2)")

        var placeID: String?
        var completionHandlerCodeComplete: Bool = false
        
        var placeTextSearchURL: String = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" + generalLocaleQueryString + "&key=" + (keys["GooglePlacesAPIKeyWeb"] as! String)
        placeTextSearchURL = placeTextSearchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("placeTextSearchURL is \(placeTextSearchURL)")
        
        let session = URLSession.shared
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
            print("Place ID BEFORE (should be nil) is \(placeID)")
            placeID = json["results"][0]["place_id"].string
            print("Made placeID OF GENERAL LOCALE equal to \(placeID)")
            
            completionHandlerCodeComplete = true
        }).resume()
        
        //DO I NEED TO IMPLEMENT PROPER COMPLETION HANDLER INTO THIS FUNCTION?????
        while (completionHandlerCodeComplete == false) {
            //print("Waiting on the photo reference to retrieve...")
        }
        print("Returning placeID OF GENERAL LOCALE of \(placeID)")
        return placeID
    }
    
    
    //Retrieve photo metadata for place
    func setPhotoMetaDataForLocation(placeID: String, completion: @escaping (_ result: Bool)->()) {
        print("In function setPhotoMetaDataForLocation...(#3)")
        print("Using place ID of \(placeID)")
        
        var photoMetaDataFindComplete: Bool = false
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                print("Error loading photo from Google API: \(error.localizedDescription)")
                completion(true)
                return
            } else {
                print("Photos count is \(photos?.results.count)")
                if let firstPhotoMetadata = photos?.results.first {
                    self.firstGeneralLocalePhotoMetaData = firstPhotoMetadata
                    photoMetaDataFindComplete = true
                    completion(true)
                }
                else {
                    print("No photos found. Resetting image view to blank...")
                    self.firstGeneralLocalePhotoMetaData = nil
                    self.firstGeneralLocalePhoto = nil
                    completion(true)
                }
            }
        }
        if (photoMetaDataFindComplete == false) {
            completion(false)
        }
    }
    
    
    //Retrieve image based on place metadata
    func setImageForMetadata(size: CGSize, scale: CGFloat, completion: @escaping (_ result: Bool) ->()) {
        print("In function setImageForMetadata...(#4)")

        var imageFindComplete: Bool = false
        if (firstGeneralLocalePhotoMetaData != nil) {
            GMSPlacesClient.shared().loadPlacePhoto(firstGeneralLocalePhotoMetaData!, constrainedTo: size, scale: scale) { (photo, error) -> Void in
                if let error = error {
                    print("Error loading image for metadata: \(error.localizedDescription)")
                    completion(true)
                    return
                } else {
                    self.firstGeneralLocalePhoto = photo
                    print("self.firstGeneralLocalePhoto is \(self.firstGeneralLocalePhoto)")
                    imageFindComplete = true
                    completion(true)
                }
            }
        }
        else {
            print("firstGeneralLocalePhotoMetaData was nil.  Exiting out of this function...")
            imageFindComplete = true
        }
        if (imageFindComplete == false) {
            completion(false)
        }
    }
}
