//
//  FlickrClient.swift
//  virtualTourist
//
//  Created by Arjun Baru on 22/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class FlickrClient: NSObject{
    
    var numberOfPhotos = 0
    
    func getImageFromFlickr(_ parameter: [String:AnyObject],completionHandler: @escaping(_ result: [String:AnyObject]?,_ error: NSError?)-> Void){
        let urlString = FlickrClient.Constants.baseUrl + FlickrClient.escapedParameters(parameter)
        let request = URLRequest(url: URL(string: urlString)!)
        let task = URLSession.shared.dataTask(with: request as URLRequest){(data,response,error) in
            guard error == nil else{
                print("cannot fin data")
                return
            }
            guard let data = data else{
                print("data empty")
                return
            }
            FlickrClient.parseJSONWithCompletionHandler(data){(result,error) in
                if error != nil{
                    completionHandler(nil,error)
                    return
                }
               completionHandler(result,error)
            }
            
        }
    task.resume()
    }
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: [String:AnyObject]?, _ error: NSError?) -> Void){
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
            return
        }
        // print(parsedResult)
        guard let revised = parsedResult as? [String:AnyObject] else{
            print("parsing failer")
            return
        }
        
        print(revised)
        
        completionHandler(revised, nil)
    }
    func getPhoto(_ imageUrl: String,completionHandler: @escaping(_ result : Data?,_ error: NSError?) -> Void){
        let request = URLRequest(url: URL(string: imageUrl)!)
        let task = URLSession.shared.dataTask(with: request){(data ,response,error) in
            if error != nil{
               completionHandler(nil,error as NSError?)
            
            }else{
                print(" data \(data)")
                completionHandler(data,nil)
            }
            
        }
        task.resume()
    }
    
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            if(!key.isEmpty) {
                // Make sure that it is a string value
                let stringValue = "\(value)"
                
                // Escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                // Append it
                urlVars += [key + "=" + "\(escapedValue!)"]
            }
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }

    
    
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

 
    
    
    
}
