Week 5 project for the Code Fellows iOS Development Accelerator
____________________________________________________________________________________________________________________
![](https://github.com/pakalewis/MapMaker/blob/master/screenshot.png)
____________________________________________________________________________________________________________________


This app allows the user to create 'georegions' and have notifications sent when physically entering or exiting the area.
The app keeps track of all monitored regions (using iCloud) and displays the regions on a MKMapView.


Features:
- MKMapView
- NSNotificationCenter
- iCloud support
- Tab bar controller
- CoreData
- NSFetchedResultsController


Monday
- Install a tab bar view controller as the root view controller of your app
- The first view content view controller of your tab bar should be your map view controller with the following functionality:
    - A map view that takes up the entire view of the view controller
    - On long press it should place a pin on the map
    - Pressing on the pin should show a callout with the title of the annotation and a button
    - Pressing the button should segue to a screen that allows the user to add a region to monitor, based on where they long pressed on the map view.

Tuesday
- Using NSNotificationCenter, communicate back to the main view controller that the user has added a reminder via the AddReminderViewController
- When the main view controller receives that notification, create a circular overlay on the map based on where the reminder is set and how large the reminder area is.
- Setup your core data stack for this app. Create a single entity, called reminder. It should have attributes for the reminder name (identifier), the date it was added, the radius, and the coordinate.

Wednesday
- Implement a Fetched Results Controller in your app to manage your table view of reminders.
- Implement iCloud in your Core Data stack.
- Test iCloud out on your device and your simulator, they should show the same data, and update appropriately using the fetched results controller.

Thursday
- Implement local notifications to fire off when the user crosses a region's boundary. Keep in mind they will fire when the app isn't in the foreground.