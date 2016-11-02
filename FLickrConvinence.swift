//
//  FLickrConvinence.swift
//  virtualTourist
//
//  Created by Arjun Baru on 22/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension FlickrClient{
    
    func flickrImages(_ pin: Pin,completionHandler: @escaping(_ result: Bool? ,_ error: NSError? )-> Void){
        var randomPageNumber: Int = 1
        
        if let numberPages = pin.pageNumber?.intValue {
            if numberPages > 0 {
                let pageLimit = min(numberPages, 20)
                randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1 }
        }
        let parameter: [String: AnyObject] = [FlickrClient.parameterKey.method: FlickrClient.parameterValues.method as AnyObject,
                         FlickrClient.parameterKey.api_key: FlickrClient.Constants.ApiKey as AnyObject,
                         FlickrClient.parameterKey.safe_search: FlickrClient.parameterValues.safeSerach as AnyObject,
                         FlickrClient.parameterKey.lat: pin.lat as AnyObject,
                         FlickrClient.parameterKey.lon: pin.long as AnyObject,
                         FlickrClient.parameterKey.extras: FlickrClient.parameterValues.extras as AnyObject,
                         FlickrClient.parameterKey.format: FlickrClient.parameterValues.format as AnyObject,
                         FlickrClient.parameterKey.nojsoncallback: FlickrClient.parameterValues.nojsoncallback as AnyObject,
            FlickrClient.jsonResponseKeys.page: randomPageNumber as AnyObject,
            FlickrClient.jsonResponseKeys.perpage: 21 as AnyObject]
        
        FlickrClient.sharedInstance().getImageFromFlickr(parameter){(result,error) in
            guard error == nil else{
                completionHandler(nil,error)
                return
            }
            print("result is : \(result)")
            if let photoDictionary = result?[FlickrClient.jsonResponseKeys.photos] as? [String:AnyObject],let photoArray = photoDictionary[FlickrClient.jsonResponseKeys.photo] as? [[String:AnyObject]],
                let numberOfPages = photoDictionary[FlickrClient.jsonResponseKeys.pages] as? Int{
                pin.pageNumber = numberOfPages as NSNumber?
                print("the photos are \(photoArray)")
                self.numberOfPhotos = photoArray.count
                
                for photo in photoArray{
                    guard let photoUrl = photo[FlickrClient.parameterValues.extras] as? String else{
                        print("url of the photo not found ")
                        return
                    }
                    guard let photoId = photo["id"] as? String else{
                        print("ID not FOund")
                        return
                    }
                  // let path = self.filePath(imageURl: photoUrl)
                    let imageUrl = NSURL(string: photoUrl)
                    let newPhoto = Photos(photoUrl: photoUrl, id: photoId, pin: pin, context: coreDatabase.persistentContainer.viewContext)
                    pin.addToPhotos(newPhoto)
                    DispatchQueue.main.async(execute: { 
                        coreDatabase.saveContext()
                    })
                    self.downloadPhotoFromUrl(imageUrl: imageUrl as! URL){(result,success,error) in
                        
                    newPhoto.image = result!
                    self.numberOfPhotos-=1
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "downloadPhotoImage.done"), object: nil)
                    
                    DispatchQueue.main.async(execute: {
                        if result != nil{
                            
                        coreDatabase.saveContext()
                        }
                    })
                    print("result = \(result)")
                        
                    }
                }
                
                completionHandler(true,nil)
            }else{
            completionHandler(nil,error)
        }
        }
        
    }
    
    
    func downloadPhotoFromUrl(imageUrl: URL,completionHandler: @escaping(_ result: NSData?,_ success: Bool,_ error: NSError?)-> Void){
        
       // print("photo URl \(photo.url)")
        let imageData = NSData(contentsOf: imageUrl)
        completionHandler(imageData,true,nil)
    
}
}
