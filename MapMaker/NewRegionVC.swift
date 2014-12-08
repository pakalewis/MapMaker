//
//  NewRegionVC.swift
//  MapMaker
//
//  Created by Parker Lewis on 11/3/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class NewRegionVC: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    var selectedAnnotation : MKAnnotation!
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var slider: UISlider!
    
    var targetedRegion : MKCoordinateRegion?
    var mapRect : MKMapRect?
    var mapWidthInMeters: Double = 500.0
    var overlay: MKCircle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Setup Nav bar
        self.title = "Add Region to Monitor"
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonPressed:")
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonPressed:")
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        
        
        // Delegates
        self.textField.delegate = self
        self.mapView.delegate = self

        
        self.myLabel.text = "Latitude: \(self.selectedAnnotation.coordinate.latitude)\nLongitude: \(self.selectedAnnotation.coordinate.longitude)"
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.mapView.setVisibleMapRect(self.mapRect!, animated: true)
        
        // determine width in meters of the visible map region
        var leftMap = MKMapPointMake(MKMapRectGetMinX(self.mapRect!), MKMapRectGetMidY(self.mapRect!))
        var rightMap = MKMapPointMake(MKMapRectGetMaxX(self.mapRect!), MKMapRectGetMidY(self.mapRect!))
        self.mapWidthInMeters = MKMetersBetweenMapPoints(leftMap, rightMap)
        
        // make the initial overlay with the radius determined from above
        var initialRadius = self.mapWidthInMeters / 2
        self.overlay = MKCircle(centerCoordinate: self.selectedAnnotation.coordinate, radius: initialRadius)
        self.mapView.addOverlay(overlay)
        self.mapView.userInteractionEnabled = false
    }
    

    func cancelButtonPressed(sender : AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func doneButtonPressed(sender : AnyObject?) {
        if self.textField.text == "" {
            var noNameAlert = UIAlertController(title: "", message: "You must enter a title for this region", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            noNameAlert.addAction(okAction)
            self.presentViewController(noNameAlert, animated: true, completion: nil)
        }
        
        // Core Data
        let managedObjectContext = appDelegate.managedObjectContext!
        
        // First check to see if a Reminder with that identifier is already stored
        var fetchRequest = NSFetchRequest(entityName: "Reminder")
        fetchRequest.predicate = NSPredicate(format:"identifier = %@", self.textField.text)
        var fetchResult = managedObjectContext.executeFetchRequest(fetchRequest, error: nil)
        if fetchResult?.count > 0 {
            var duplicateAlert = UIAlertController(title: "", message: "There is already a reminder with this name", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            duplicateAlert.addAction(okAction)
            self.presentViewController(duplicateAlert, animated: true, completion: nil)
        }
        else {
            // Make new region to monitor
            var newRegionToMonitor = CLCircularRegion(center: self.selectedAnnotation.coordinate, radius: self.mapWidthInMeters * Double(self.slider.value), identifier: self.textField.text)
            println("new region called \(self.textField.text) added at \(newRegionToMonitor.center.latitude) and \(newRegionToMonitor.center.longitude)")
            appDelegate.locationManager.startMonitoringForRegion(newRegionToMonitor)
            
            // make new entity to store in core data
            let newReminderToStore = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: managedObjectContext) as Reminder
            newReminderToStore.identifier = self.textField.text
            newReminderToStore.date = NSDate()
            newReminderToStore.latitude = selectedAnnotation.coordinate.latitude
            newReminderToStore.longitude = selectedAnnotation.coordinate.longitude
            newReminderToStore.radius = newRegionToMonitor.radius
            
            var error : NSError?
            managedObjectContext.save(&error)
            if error != nil {
                println("There was an error saving to core data. The error says \(error!.localizedDescription)")
            }
            
            
            // Post a notification
            let newRegionNotification = NSNotification(name: "NEW_REGION_ADDED", object: nil, userInfo: ["region" : newRegionToMonitor])
            NSNotificationCenter.defaultCenter().postNotification(newRegionNotification)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        // Make renderer which draws the overlays on the map
        let renderer = MKCircleRenderer(overlay: overlay)
        // Adjust settings on the renderer
        renderer.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
        // Return it
        return renderer
    }

    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        return true
    }
    
    @IBAction func sliderSlid(sender: AnyObject) {
        // remove old overlay
        self.mapView.removeOverlay(self.overlay)
        // calculate new radius and add new overlay
        var newRadius = self.mapWidthInMeters * Double(self.slider.value)
        self.overlay = MKCircle(centerCoordinate: self.selectedAnnotation.coordinate, radius: newRadius)
        self.mapView.addOverlay(self.overlay)
    }
    
    @IBAction func addRegionButton(sender: AnyObject) {
    }
}
