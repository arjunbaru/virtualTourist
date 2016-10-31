//
//  ViewController.swift
//  virtualTourist
//
//  Created by Arjun Baru on 19/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController,MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var selectedPin: Pin? = nil
    var flag:Bool = false
    var pins = [Pin]()
    var location = MKPointAnnotation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapWithExistingPins()
        let uilgr = UILongPressGestureRecognizer(target: self, action:#selector(MapViewController.action(_:)))
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)
    }

    @IBAction func editButtonPressed(_ sender: AnyObject) {
        if flag == false{
            flag = true
            warningLabel.isHidden = false
            editButton.title = "Done"
            
        }else{
            flag =  false
            warningLabel.isHidden = true
            editButton.title = "Edit"
        }
    }
    
    func action(_ gestureRecoganiser: UIGestureRecognizer ){
        if flag{
            return
        }
        if gestureRecoganiser.state != .began {return}
        
        
        let touchPoint = gestureRecoganiser.location(in: self.mapView)
        let touchMapCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinates
        location.coordinate = touchMapCoordinates
       
        let newPin = Pin(lat: annotation.coordinate.latitude, long: annotation.coordinate.longitude, context: coreDatabase.persistentContainer.viewContext)
        pins.append(newPin)
        FlickrClient.sharedInstance().flickrImages(newPin){(success,error) in
            print("downloadPhotosForPin is success:\(success) - error:\(error)")
        }
         coreDatabase.saveContext()
        mapView.addAnnotation(annotation)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    print("clicked")
        mapView.deselectAnnotation(view.annotation, animated: true)
    
        guard let annotation = view.annotation else{print("cannottttt")
            return}
    selectedPin = nil
        for pin in pins{
        if annotation.coordinate.latitude == pin.lat && annotation.coordinate.longitude == pin.long{
            selectedPin = pin
            if flag{
                print("deleting pin")
                coreDatabase.persistentContainer.viewContext.delete(selectedPin!)
                coreDatabase.saveContext()
                self.mapView.removeAnnotation(annotation)
            }else{
                 self.location = annotation as! MKPointAnnotation
                  self.performSegue(withIdentifier: "photoAlbum", sender: self)
            }
        }
    }
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoAlbum"{
            let controller = segue.destination as! PhotoAlbumViewController
           controller.location = self.location
            controller.pin = self.selectedPin
    }
}
    func loadMapWithExistingPins(){
        let fetchRequest = NSFetchRequest<Pin>(entityName:"Pin")
        do{
            let searchResult = try coreDatabase.persistentContainer.viewContext.fetch(fetchRequest)
             var annotations = [MKPointAnnotation]()
            for s in searchResult{
                 pins.append(s)
                let lat = CLLocationDegrees(s.lat)
                
                let long = CLLocationDegrees(s.long)
                let coordinates = CLLocationCoordinate2D(latitude: lat,longitude: long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
        }catch{
            print("error : \(error)")
            
        }
        
    }
   
    
}
