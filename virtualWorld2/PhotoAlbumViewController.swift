//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Arjun Baru on 21/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource{
    let image:UIImageView? = nil
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var actionButton: UIButton!
    
    
    var selectedIndex = [IndexPath]()
    var pin: Pin? = nil
    var flag : Bool = false
    var select: Bool = false
    var totalLoadedPhotos = [IndexPath]()
    var fetchedResultController: NSFetchedResultsController<Photos>!
    var location: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.setTitle("New Collection", for: UIControlState())
       // print("Pin IS \(pin?.lat)")
        loadData()
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    
    func loadData(){
        let fetchRequest =  NSFetchRequest<Photos>(entityName: "Photos")
        let NOC = coreDatabase.persistentContainer.viewContext
        
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        
        let frc = NSFetchedResultsController<Photos>(fetchRequest: fetchRequest, managedObjectContext: NOC, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController = frc
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            print("\(error)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoAlbumViewController.photoReload(_:)), name: NSNotification.Name(rawValue: "downloadPhotoImage.done"), object: nil)
        
        loadMap()
        
    }

    
    
    @IBAction func actionButton(_ sender: AnyObject) {
        if !flag{
            
            for index in totalLoadedPhotos{
                let photo = fetchedResultController.object(at: index)
                coreDatabase.persistentContainer.viewContext.delete(photo)
            }
            coreDatabase.saveContext()
            FlickrClient.sharedInstance().flickrImages(pin!){(success,error) in
                if success!{
                    DispatchQueue.main.async(execute: {
                        coreDatabase.saveContext()
                    })
                }else{
                    print("error file downloading new set")
                }
                DispatchQueue.main.async(execute: {
                self.reFetch()
                self.collectionView.reloadData()
                })
            }
            
        }else{
            for index in selectedIndex{
                let photo = fetchedResultController.object(at: index)
                print("deleting : \(photo)")
                coreDatabase.persistentContainer.viewContext.delete(photo)
                
               
            }
            totalLoadedPhotos.removeAll()
            selectedIndex.removeAll()
            reFetch()
            self.collectionView.reloadData()
             coreDatabase.saveContext()
            actionButton.setTitle("New Collection", for: UIControlState())
            flag = false
        }
    }
    // MARK: collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultController.sections![section]
        print("Number of photos returned from fetchedResultsController #\(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumViewController", for: indexPath) as! PhotoCollectionViewCell
       cell.imageView.alpha = 1.0
            let photo = fetchedResultController.object(at: indexPath)
            print("pho== \(photo.image)")
        
        let hppp = UIImage(data: photo.image as! Data)
        
    totalLoadedPhotos.append(indexPath)
        print("imageee :\(hppp)")
        
           cell.imageView.image = hppp
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        collectionView.deselectItem(at: indexPath, animated: true)
        if let index = selectedIndex.index(of: indexPath){
            selectedIndex.remove(at: index)
            cell.imageView.alpha = 1.0
            actionButton.setTitle("New Collection", for: UIControlState())
        }else{
            selectedIndex.append(indexPath)
            cell.imageView.alpha = 0.5
            actionButton.setTitle("Delete", for: UIControlState())
            flag = true
        }
    }
    
    
    func setImage(filePath: String)-> UIImage{
        let fileName = (filePath as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathArray = [dirPath, fileName]
        let fileURL = NSURL.fileURL(withPathComponents: pathArray)
        
        return UIImage(contentsOfFile: fileURL!.path)!
    }
    
}
//MARK: mapView

extension PhotoAlbumViewController{
   
    func loadMap(){
        
        let lat = CLLocationDegrees((location?.coordinate.latitude)!)
        let long = CLLocationDegrees((location?.coordinate.longitude)!)
        let coordinate = CLLocationCoordinate2D(latitude: lat,longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.addAnnotation(annotation)
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)
    }

    @objc(mapView:viewForAnnotation:) func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
}
// MARK: Supporting functions
extension PhotoAlbumViewController{
    fileprivate func reFetch() {
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            print("reFetch - \(error)")
        }
    }
    
    func photoReload(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            self.reFetch()
            self.collectionView.reloadData()
            
            // If no photos remaining, show the 'New Collection' button
            let numberRemaining = FlickrClient.sharedInstance().numberOfPhotos
            print("numberRemaining is from photoReload \(numberRemaining)")
            
        })
    }
    
}
