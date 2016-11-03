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
    
    static private var keys: NSDictionary = NSDictionary()
    static private var baseURL: String = "https://maps.googleapis.com/maps/api/place/"
    static private var placesClient: GMSPlacesClient? = GMSPlacesClient.shared()
    
    static var currentPlace: Place?
    
    static var placeIDOfGeneralLocale: String?    
    static var currentPlaceImageIndex: Int?
    
    //Private initializer prevents any outside code from using the default '()' initializer for this class, which could create duplicates of LocationAPIService
    private init() {}
    
    //Load the Google Places API keys from APIKeys.plist
    class public func setAPIKeys() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        keys = NSDictionary(contentsOfFile: path)!
    }
    
    
    //This method gets the current location of the user and sets currentPlace
    class public func setCurrentLocationPlace(completion: @escaping (_ result: Bool)->()) {
        print("In function setCurrentLocationPlace...")

        var placeFindComplete: Bool = false
        
        currentPlaceImageIndex = nil
        
        LocationAPIService.placesClient?.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                LocationAPIService.currentPlace = nil
                
                completion(true)

                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                let firstPlaceFound = placeLikelihoods.likelihoods.first?.place

                LocationAPIService.currentPlace = Place(place: firstPlaceFound)

                
                placeFindComplete = true
                
                completion(true)
            }
        })
        if (placeFindComplete == false) {
            completion(false)
        }
    }
    
    
    //This method finds a photo of the general locale
    class public func setPhotoOfGeneralLocale(size: CGSize, scale: CGFloat, completion: @escaping (_ result: Bool) ->()) {
        print("In function setPhotoOfGeneralLocale...")
        let generalLocaleString: String? = LocationAPIService.currentPlace?.getGeneralLocaleString()
        
        //Get the place ID of the general area so that we can grab an image of the city
        LocationAPIService.setPlaceIDOfGeneralLocale(generalLocaleQueryString: generalLocaleString)

        if (LocationAPIService.placeIDOfGeneralLocale != nil) {
            LocationAPIService.setPhotoMetaData() { (photoMetaDataFound) -> () in
                if (photoMetaDataFound == true) {
                    LocationAPIService.setImagesArrayForMetadata(size: size, scale: scale) { (imageFound) -> () in
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
    
    
    //This method takes a general area string (such as "Atlanta, Georgia, United States") and gets a place ID for that area
    class private func setPlaceIDOfGeneralLocale(generalLocaleQueryString: String?) {
        print("In function getPlaceIDOfGeneralLocale...(#2)")

        var placeID: String?
        var completionHandlerCodeComplete: Bool = false
        
        var placeTextSearchURL: String = LocationAPIService.baseURL + "textsearch/json?query=" + generalLocaleQueryString! + "&key=" + (LocationAPIService.keys["GooglePlacesAPIKeyWeb"] as! String)

        placeTextSearchURL = placeTextSearchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
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
            placeID = json["results"][0]["place_id"].string
            
            completionHandlerCodeComplete = true
        }).resume()
        
        //DO I NEED TO IMPLEMENT PROPER COMPLETION HANDLER INTO THIS FUNCTION?????
        while (completionHandlerCodeComplete == false) {
            //print("Waiting on the photo reference to retrieve...")
        }
        print("Returning placeID OF GENERAL LOCALE of \(placeID)")
        LocationAPIService.placeIDOfGeneralLocale = placeID
    }
    
    
    //Retrieve photo metadata for place
    class private func setPhotoMetaData(completion: @escaping (_ result: Bool)->()) {
        print("In function setPhotoMetaDataForLocation...(#3)")
        
        var photoMetaDataFindComplete: Bool = false
        
        LocationAPIService.placesClient?.lookUpPhotos(forPlaceID: LocationAPIService.placeIDOfGeneralLocale!) { (photos, error) -> Void in
            if let error = error {
                print("Error loading photo from Google API: \(error.localizedDescription)")
                completion(true)
                return
            } else {
                print("Photos count is \(photos?.results.count)")
                
                if ((photos?.results.count)! > 0) {
                    LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray = (photos?.results)!
                    
                    photoMetaDataFindComplete = true
                    completion(true)
                }
                else {
                    print("No photos found. Resetting image view to blank...")
                    
                    LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray.removeAll()
                    LocationAPIService.currentPlace?.generalLocalePhotoArray.removeAll()
                    
                    LocationAPIService.currentPlaceImageIndex = nil
                    
                    completion(true)
                }
            }
        }
        if (photoMetaDataFindComplete == false) {
            completion(false)
        }
    }
    
    
    //Retrieve image based on place metadata
    class private func setImagesArrayForMetadata(size: CGSize, scale: CGFloat, completion: @escaping (_ result: Bool) ->()) {
        //print("In function setImagesArrayForMetadata...(#4)")

        var imageArrayFindComplete: Bool = false
        if (LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray != nil) {
            
            var isIndexSet: Bool = false
            
            for photoMetaDataIndex in 0..<(LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray)!.count {
                setImageForMetaData(index: photoMetaDataIndex, size: size, scale: scale) { imageSet -> () in
                    if (imageSet) {
                        //If this is the first photo successfully retrieved, set the currentPlaceImageIndex to 0 instead of nil
                        if (!isIndexSet) {
                            LocationAPIService.currentPlaceImageIndex = 0
                            isIndexSet = true
                        }
                        
                        //If we are on the last element, mark completion as true
                        if (photoMetaDataIndex == (LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray)!.count - 1) {
                            print("On last element in photo meta data array.  mark completion...")
                            imageArrayFindComplete = true
                            completion(true)
                        }
                        completion(imageArrayFindComplete)
                    }
                }
            }
        }
        else {
            print("generalLocalePhotoMetaDataArray was empty.  Exiting out of this function...")
            imageArrayFindComplete = true
        }
        if (imageArrayFindComplete == false) {
            completion(false)
        }
    }
    
    
    class private func setImageForMetaData(index: Int, size: CGSize, scale: CGFloat, completion: @escaping (_ result: Bool) -> ()) {
        print("In function setImageForMetadata...(#4)")

        var imageFindComplete: Bool = false
        
        if (LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray[index] != nil) {
            LocationAPIService.placesClient?.loadPlacePhoto((LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray[index])!, constrainedTo: size, scale: scale) { (photo, error) -> Void in
                if let error = error {
                    print("Error loading image for metadata: \(error.localizedDescription)")
                    completion(true)
                    return
                } else {                    
                    LocationAPIService.currentPlace?.generalLocalePhotoArray.append(photo)
                    
                    imageFindComplete = true
                    completion(true)
                }
            }
        }
        else {
            print("GeneralLocalePhotoMetaData for this index was nil.  Exiting out of this function...")
            imageFindComplete = true
        }

        if (imageFindComplete == false) {
            completion(false)
        }
    }
}
