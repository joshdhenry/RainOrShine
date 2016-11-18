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
    // MARK: - Properties
    typealias PlaceResult = (_ result: Bool, _ generalLocalePlace: Place?)->()
    typealias Result = (_ result: Bool) ->()

    static private var keys: NSDictionary = NSDictionary()
    static private var baseURL: String = "https://maps.googleapis.com/maps/api/place/"
    static private var placesClient: GMSPlacesClient? = GMSPlacesClient.shared()
    
    static var currentPlace: Place?
    static var generalLocalePlace: Place?
    
    static var currentPlaceImageIndex: Int = 0
    
    
    // MARK: - Initializer
    //Private initializer prevents any outside code from using the default '()' initializer for this class, which could create duplicates of LocationAPIService
    private init() {}
    
    
    // MARK: - Methods
    //Load the Google Places API keys from APIKeys.plist
    class public func setAPIKeys() {
        print("In func setAPIKeys...")
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        keys = NSDictionary(contentsOfFile: path)!
    }
    
    
    //This method gets the current location of the user and sets currentPlace
    class public func setCurrentExactPlace(completion: @escaping PlaceResult) {
        print("In function setCurrentExactPlace...")
        print(LocationAPIService.placesClient)

        var placeFindComplete: Bool = false
        print("START")
        LocationAPIService.placesClient?.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            print("ZERO")
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                
                placeFindComplete = true
                completion(true, nil)
                return
            }
            
            guard let thisPlaceLikelihoods = placeLikelihoods else {
                print("ONE")
                completion(true, nil)
                return
            }
            guard let firstPlaceLikelihoodFound = thisPlaceLikelihoods.likelihoods.first else {
                print("TWO")

                completion(true, nil)
                return
            }
            print("THREE")

            let placeToReturn: Place = Place(place: firstPlaceLikelihoodFound.place)
            
            print("RETURNING \(firstPlaceLikelihoodFound.place.formattedAddress)")
            print("RETURNING \(placeToReturn.gmsPlace?.formattedAddress)")
            placeFindComplete = true
            completion(true, placeToReturn)
        })
        print("FOUR")

        if (!placeFindComplete) {
            print("STILL FINDING EXACT PLACE")
            completion(false, nil)
        }
    }
    
    
    class public func setGeneralLocalePlace(completion: @escaping PlaceResult) {
        var placeFindComplete: Bool = false
        
        let generalLocaleString: String = LocationAPIService.currentPlace?.getGeneralLocaleString() ?? ""
        
        //Get the place ID of the general area so that we can grab an image of the city
        let placeIDOfGeneralLocale: String? = LocationAPIService.getPlaceIDOfGeneralLocale(generalLocaleQueryString: generalLocaleString)
        
        //Some places, like Lake Superior (47, -90) do not return a general locale string because it only has a formatted string of type natural_feature
        //In that case, set the general locale to the exact location
        if (placeIDOfGeneralLocale == nil) {
            placeFindComplete = true
            let placeToReturn: Place? = LocationAPIService.currentPlace
            
            completion(true, placeToReturn)
        }
        //Else, return the general locale place
        else {
            LocationAPIService.placesClient?.lookUpPlaceID(placeIDOfGeneralLocale!, callback: { (place, error) -> Void in
                guard error == nil else {
                    print("General Locale Place error: \(error!.localizedDescription)")
                    
                    placeFindComplete = true
                    completion(true, nil)
                    return
                }
                guard let thisPlace = place else {
                    print("Error - the data received does not conform to Place class.")
                    
                    placeFindComplete = true
                    completion(true, nil)
                    return
                }
                
                placeFindComplete = true
                
                let placeToReturn: Place = Place(place: thisPlace)
                
                completion(true, placeToReturn)
            })
        }
        if (!placeFindComplete) {
            completion(placeFindComplete, nil)
        }
    }
    
    
    //This method finds a photo of the general locale
    class public func setPhotosOfGeneralLocale(size: CGSize, scale: CGFloat, completion: @escaping Result) {
        //print("In function setPhotoOfGeneralLocale...")
        if (LocationAPIService.generalLocalePlace?.gmsPlace != nil) {

            LocationAPIService.setPhotoMetaData(placeIDOfGeneralLocale: LocationAPIService.generalLocalePlace?.gmsPlace?.placeID) { (photoMetaDataFound) -> () in
                if (photoMetaDataFound) {
                    print("FOUND METADATA")
                    LocationAPIService.setImagesArrayForMetadata(size: size, scale: scale) { (imageFound) -> () in
                        if (imageFound) {
                            completion(true)
                        }
                    }
                }
            }
        }
        else {
            print("Not loading a photo since place of general area was nil...")
            completion(true)
        }
    }
    
    
    
    //This method takes a general area string (such as "Atlanta, Georgia, United States") and gets a place ID for that area
    class private func getPlaceIDOfGeneralLocale(generalLocaleQueryString: String?) -> String? {
        //print("In function getPlaceIDOfGeneralLocale...(#2)")

        var placeID: String?
        var completionHandlerCodeComplete: Bool = false
        
        var placeTextSearchURL: String = LocationAPIService.baseURL + "textsearch/json?query=" + generalLocaleQueryString! + "&key=" + (LocationAPIService.keys["GooglePlacesAPIKeyWeb"] as! String)

        placeTextSearchURL = placeTextSearchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let session = URLSession.shared
        let url = URL(string: placeTextSearchURL)!
        
        // Make call. Handle it in a completion handler.
        session.dataTask(with: url as URL, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            //Ensure the  response isn't an error
            guard (error == nil && data != nil) else {
                print("Error - failed to download place data...")
                return
            }
            guard let thisURLResponse = response as? HTTPURLResponse,
                thisURLResponse.statusCode == 200 else {
                    print("Not a 200 (successful) response")
                    completionHandlerCodeComplete = true
                    return
            }
            let json = JSON(data: data!)
            
            placeID = json["results"][0]["place_id"].string
            
            completionHandlerCodeComplete = true
        }).resume()
                
        while (!completionHandlerCodeComplete) {
            //print("Waiting on the photo reference to retrieve...")
        }
        return placeID
    }
    
    
    //Retrieve photo metadata for place
    class private func setPhotoMetaData(placeIDOfGeneralLocale: String?, completion: @escaping Result) {
        //print("In function setPhotoMetaDataForLocation...(#3)")
        
        var photoMetaDataFindComplete: Bool = false
        
        LocationAPIService.placesClient?.lookUpPhotos(forPlaceID: placeIDOfGeneralLocale!) { (photos, error) -> Void in
            guard (error == nil) else {
                print("Error loading photo from Google API: \(error?.localizedDescription)")
                photoMetaDataFindComplete = true
                completion(true)
                return
            }
            
            guard let photosList = photos else {
                print("Error - Photos returned from lookup are nil.")
                photoMetaDataFindComplete = true
                completion(true)
                return
            }
            
            print("Photos count is \(photosList.results.count)")
            
            if (!photosList.results.isEmpty) {
                LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray = (photos?.results)!
            }
            photoMetaDataFindComplete = true
            completion(true)
        }
        if (!photoMetaDataFindComplete) {
            completion(false)
        }
    }
    
    
    //Retrieve image based on place metadata
    class private func setImagesArrayForMetadata(size: CGSize, scale: CGFloat, completion: @escaping Result) {
        print("In function setImagesArrayForMetadata...(#4)")

        var imageArrayFindComplete: Bool = false
        
        guard let currentPlace = LocationAPIService.currentPlace else {
            print("Error setting images array for metadata. Place was nil.")
            
            imageArrayFindComplete = true
            completion(true)
            return
        }
        
        if (!currentPlace.generalLocalePhotoMetaDataArray.isEmpty) {
            for photoMetaDataIndex in 0..<currentPlace.generalLocalePhotoMetaDataArray.count {
                setImageForMetaData(index: photoMetaDataIndex, size: size, scale: scale) { imageSet -> () in
                    if (imageSet) {
                        //If we are on the last element, mark completion as true
                        if (photoMetaDataIndex == currentPlace.generalLocalePhotoMetaDataArray.count - 1) {
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
            completion(imageArrayFindComplete)
        }
        if (!imageArrayFindComplete) {
            completion(imageArrayFindComplete)
        }
    }
    
    
    //Cycle through generalLocalePhotoMetaDataArray and perform a request for each image and populate generalLocalePhotoArray with UIImages
    class private func setImageForMetaData(index: Int, size: CGSize, scale: CGFloat, completion: @escaping Result) {
        //print("In function setImageForMetadata...(#4)")

        var imageFindComplete: Bool = false
        
        if (LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray[index] != nil) {
            LocationAPIService.placesClient?.loadPlacePhoto((LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray[index])!, constrainedTo: size, scale: scale) { (photo, error) -> Void in
                if let error = error {
                    print("Error loading image for metadata: \(error.localizedDescription)")
                    
                    imageFindComplete = true
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
            //GeneralLocalePhotoMetaData for this index was nil.  Exiting out of this function.
            imageFindComplete = true
        }
        if (!imageFindComplete) {
            completion(imageFindComplete)
        }
    }
}
