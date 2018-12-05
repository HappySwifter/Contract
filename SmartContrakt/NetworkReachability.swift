//
//  NetworkReachability.swift
//  C-Systems
//
//  Created by Valery Domozhirov on 26.05.16.
//  Copyright © 2015,2016 Joylight Rus Ltd. All rights reserved.
//

//

import Foundation
import SystemConfiguration

/// Reachability Changed Notification
public let DVAReachabilityChangedNotification = "DVANetworkReachabilityChangedNotification"

/// Network Reachability Protocol
public protocol NetworkReachabilityProtocol {
    /// check the reachability of a given host name
    static func reachabilityWithHostName(_ hostName: String) -> NetworkStatus
    /// start listening for reachability notifications
    func startNotifier()
    /// stop listening for reachability notifications
    func stopNotifier()
    /// current reachability status
    var currentReachabilityStatus: NetworkStatus { get }
}

/// Network Status
public enum NetworkStatus {
    case notReachable, reachableViaWiFi, reachableViaWWAN

    public var description: String {
        switch self {
        case .reachableViaWWAN:
            return "2G/3G/4G"
        case .reachableViaWiFi:
            return "WiFi"
        case .notReachable:
            return "No Connection"
        }
    }
}

private func & (lhs: SCNetworkReachabilityFlags, rhs: SCNetworkReachabilityFlags) -> UInt32 { return lhs.rawValue & rhs.rawValue }

/// Network Reachability
open class NetworkReachability: NetworkReachabilityProtocol {

    open static func reachabilityWithHostName(_ hostName: String) -> NetworkStatus {
        let reach = NetworkReachability(hostname: hostName)

        return reach.currentReachabilityStatus
    }

    fileprivate var reachability: SCNetworkReachability?
    public init(hostname: String) {
        reachability = SCNetworkReachabilityCreateWithName(nil, hostname)!
    }

    deinit {
        stopNotifier()

        if reachability != nil {
            reachability = nil
        }
    }

    /// start listening for reachability notifications
    open func startNotifier() {
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)

        SCNetworkReachabilitySetCallback(reachability!, { (_, _, _) in
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: DVAReachabilityChangedNotification), object: nil)
            }, &context)
        SCNetworkReachabilityScheduleWithRunLoop(reachability!, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)

    }

    /// stop listening for reachability notifications
    open func stopNotifier() {
        if reachability != nil {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability!, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        }
    }

    /// current reachability status
    open var currentReachabilityStatus: NetworkStatus {

        if reachability == nil {
            return NetworkStatus.notReachable
        }

        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        SCNetworkReachabilityGetFlags(reachability!, &flags)

        return networkStatus(flags)
    }

    func networkStatus(_ flags: SCNetworkReachabilityFlags) -> NetworkStatus {
        if (flags & SCNetworkReachabilityFlags.reachable == 0) {
            // // The target host is not reachable.
            return NetworkStatus.notReachable
        }

        var returnValue = NetworkStatus.notReachable
        if flags & SCNetworkReachabilityFlags.connectionRequired == 0 {
            // If the target host is reachable and no connection is required
            // then we'll assume (for now) that you're on Wi-Fi...
            returnValue = NetworkStatus.reachableViaWiFi
        }

        if flags & SCNetworkReachabilityFlags.connectionOnDemand != 0 || flags & SCNetworkReachabilityFlags.connectionOnTraffic != 0 {

            // ... and the connection is on-demand (or on-traffic)
            // if the calling application is using the CFSocketStream or higher APIs...
            if flags & SCNetworkReachabilityFlags.interventionRequired == 0 {

                // ... and no [user] intervention is needed...
                returnValue = NetworkStatus.reachableViaWiFi
            }
        }

        if (flags & SCNetworkReachabilityFlags.isWWAN) == SCNetworkReachabilityFlags.isWWAN.rawValue {
            // ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
            returnValue = NetworkStatus.reachableViaWWAN
        }

        return returnValue
    }
}
