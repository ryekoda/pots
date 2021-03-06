//
//  AppDelegate.swift
//  Pots
//
//  Created by Ryan on 4/7/18.
//  Copyright © 2018 pots. All rights reserved.
//

import UIKit
import PubNub

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    var window: UIWindow?
    var client: PubNub!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isStatusBarHidden = false
        setupNavBar()
        
        // Initialize and configure PubNub client instance
        let configuration = PNConfiguration(publishKey: "pub-c-e0032c5e-fe30-48c8-a743-c4734119131d", subscribeKey: "sub-c-065072d0-224c-11e7-9093-0619f8945a4f")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        // Subscribe to demo channel with presence observation
        self.client.subscribeToChannels(["my_channel"], withPresence: true)
        
        return true
    }
    
    fileprivate func setupNavBar() {
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 36.0/255.0, green:33.0/255.0, blue: 62.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        if let barFont = UIFont(name: "Helvetica-Neue", size: 24.0) {
            if #available(iOS 11.0, *) {
                UINavigationBar.appearance().largeTitleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white, kCTFontAttributeName: barFont] as [NSAttributedStringKey : Any] as [NSAttributedStringKey : Any]
            } else {
                UINavigationBar.appearance().titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white, kCTFontAttributeName: barFont] as [NSAttributedStringKey : Any]
            }
        }
        
        UITabBar.appearance().tintColor = .orange
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.channel != message.data.subscription {
            
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            
            // Message has been received on channel stored in message.data.channel.
        }
        
        print("Received message: \(message.data.message) on channel \(message.data.channel) " +
            "at \(message.data.timetoken)")
        
        let notiName = Notification.Name("pushNotification")
        NotificationCenter.default.post(name: notiName, object: nil, userInfo: nil)
    }
    
    // New presence event handling.
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout, state-change).
        if event.data.channel != event.data.subscription {
            
            // Presence event has been received on channel group stored in event.data.subscription.
        }
        else {
            
            // Presence event has been received on channel stored in event.data.channel.
        }
        
        if event.data.presenceEvent != "state-change" {
            
            print("\(event.data.presence.uuid) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) on \(event.data.channel) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            print("\(event.data.presence.uuid) changed state at: " +
                "\(event.data.presence.timetoken) on \(event.data.channel) to:\n" +
                "\(event.data.presence.state)");
        }
    }
    
    // Handle subscription status change.
    func client(_ client: PubNub, didReceive status: PNStatus) {
        
        if status.operation == .subscribeOperation {
            
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    
                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
                    
                    // Select last object from list of channels and send message to it.
//                    let targetChannel = client.channels().last!
//                    client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
//                                   compressed: false, withCompletion: { (publishStatus) -> Void in
//
//                                    if !publishStatus.isError {
//
//                                        // Message successfully published to specified channel.
//                                    }
//                                    else {
//
//                                        /**
//                                         Handle message publish error. Check 'category' property to find out
//                                         possible reason because of which request did fail.
//                                         Review 'errorData' property (which has PNErrorData data type) of status
//                                         object to get additional information about issue.
//
//                                         Request can be resent using: publishStatus.retry()
//                                         */
//                                    }
//                    })
                }
                else {
                    
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                }
            }
            else if status.category == .PNUnexpectedDisconnectCategory {
                
                /**
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {
                
                let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                }
                else {
                    
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories
                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                     or `PNNetworkIssuesCategory`
                     */
                }
            }
        }
    }
}

