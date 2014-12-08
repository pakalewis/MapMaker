//
//  MonitoredRegionsVC.swift
//  MapMaker
//
//  Created by Parker Lewis on 11/3/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MonitoredRegionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var managedObjectContext : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Monitored Regions"
        
        let monitoredRegions = self.appDelegate.locationManager.monitoredRegions
        for region in monitoredRegions {
            println("REGIONS:\n\(region.identifier)")
        }

        
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.managedObjectContext = self.appDelegate.managedObjectContext!
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetCloudChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: appDelegate.persistentStoreCoordinator)

        
        // make a fetch request to core data to get all Reminders
        var fetchRequest = NSFetchRequest(entityName: "Reminder")
        var sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // initialize FRC
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Reminders")
        self.fetchedResultsController.delegate = self
        
        var error : NSError?
        if !self.fetchedResultsController.performFetch(&error) {
            println("error!!")
        }
        self.refreshMonitoredRegions()

    }

    
    func didGetCloudChanges(notification : NSNotification)
    {
        println("DID GET CLOUD CHANGES")
        self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
        self.refreshMonitoredRegions()
        self.tableView.reloadData()
    }

    
    func refreshMonitoredRegions() {
        let monitoredRegions = self.appDelegate.locationManager.monitoredRegions
        let reminders = self.fetchedResultsController.fetchedObjects as [Reminder]
        for reminder in reminders {
            let identifier = reminder.identifier
            let targetPredicate = NSPredicate(format:"identifier = %@", identifier)
            let filteredSet = monitoredRegions.filteredSetUsingPredicate(targetPredicate!)
            
            if filteredSet.count == 0 {
                println("the reminder \(reminder.identifier) was not being monitored. But now it is!")
                var newRegionToMonitor = CLCircularRegion(center: reminder.makeCoordinate(), radius: reminder.radius, identifier: reminder.identifier)
                self.appDelegate.locationManager.startMonitoringForRegion(newRegionToMonitor)
                
                let newRegionNotification = NSNotification(name: "NEW_REGION_ADDED", object: nil, userInfo: ["region" : newRegionToMonitor])
                NSNotificationCenter.defaultCenter().postNotification(newRegionNotification)

            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("reloading table view in controllerDidChangeContent")
        self.tableView.reloadData()
    }
    
    
    // MARK: Tableview funcs
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("REGION_CELL", forIndexPath: indexPath) as UITableViewCell
        
        // get appropriate region
        let currentReminder = self.fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder
        
        cell.textLabel.text = currentReminder.identifier
        return cell
    }

    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // User deleted region from tableview.
        if editingStyle == .Delete {
            
            // delete monitored region
            let allRegions = self.appDelegate.locationManager.monitoredRegions
            let identifier = self.fetchedResultsController.objectAtIndexPath(indexPath).identifier
            let targetPredicate = NSPredicate(format:"identifier = %@", identifier)
            println("identifier of region to stop monitoring: \(identifier)")
            let filteredSet = allRegions.filteredSetUsingPredicate(targetPredicate!)
            if let regionToStopMonitoring = filteredSet.allObjects.first as? CLRegion {
                self.appDelegate.locationManager.stopMonitoringForRegion(regionToStopMonitoring)
            }
            

            
            // delete from CoreData
            if let objectToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject {
                self.managedObjectContext.deleteObject(objectToDelete)
            }
            var error: NSError? = nil
            if !self.managedObjectContext.save(&error) {
                println("Error saving context: \(error)")
                abort()
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
        let currentReminder = self.fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder

        var selectedRegionVC = self.storyboard?.instantiateViewControllerWithIdentifier("SPECIAL") as SelectedRegionVC
        selectedRegionVC.selectedRegion = currentReminder
        self.navigationController?.pushViewController(selectedRegionVC, animated: true)
        
        
        
    }
    
    
}
