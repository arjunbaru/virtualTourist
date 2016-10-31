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
                    
                    
                   self.downloadPhotoFromUrl(photoString: photoUrl){(result,success,error) in
                    let newPhoto = Photos.init(photoUrl: photoUrl, id: photoId, filePath: result!, pin: pin, context: coreDatabase.persistentContainer.viewContext)
                    pin.addToPhotos(newPhoto)
                    print("NEW PHOTOOOO\(newPhoto.filePath)")
                    
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
    
    
    func downloadPhotoFromUrl(photoString: String,completionHandler: @escaping(_ result: String?,_ success: Bool,_ error: NSError?)-> Void){
        let imageUrl = photoString
       // print("photo URl \(photo.url)")
        self.getPhoto(imageUrl){(data,error) in
            if error != nil{
                print("error while downloading image")
              //  photo.filePath = "error"
                completionHandler(nil,false,error)
                
            }else{
                let fileName = (imageUrl as NSString).lastPathComponent
                let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let pathArray = [dirPath, fileName]
                let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
                print("Data : \(data)")
                FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil)
               // photo.filePath = fileURL.path
               // print("........\(photo.filePath)")
                print("DownloadSaved")
                completionHandler(fileURL.path,true,nil)
            
            }
        }
        
    }
    
    
}
