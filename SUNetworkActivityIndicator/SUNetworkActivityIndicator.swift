//
//  SUNetworkActivityIndicator.swift
//
//  Created by Suguru Kishimoto on 2015/12/17.

import Foundation
import UIKit

/**
 Notification name for `activeCount` changed.

 Contains `activeCount` in notification.object as `Int`
 */
public let NetworkActivityIndicatorActiveCountChangedNotification = "ActiveCountChanged"

/// NetworkActivityIndicator
open class NetworkActivityIndicator {

  /// Singleton: shared instance (private var)
  fileprivate static let sharedInstance = NetworkActivityIndicator()

  /// enable sync access (like Objective-C's `@synchronized`)
  fileprivate let syncQueue = DispatchQueue(
    label: "NetworkActivityIndicatorManager.syncQueue",
    attributes: []
  )

  /**
   ActiveCount

   If count is above 0,

   ```
   UIApplication.sharedApplication().networkActivityIndicatorVisible
   ```

   is true, else false.
  */
  fileprivate(set) open var activeCount: Int {
    didSet {
      UIApplication.shared
        .isNetworkActivityIndicatorVisible = activeCount > 0
      if activeCount < 0 {
        activeCount = 0
      }
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: NetworkActivityIndicatorActiveCountChangedNotification),
        object: activeCount
      )
    }
  }

  /**
   Initializer (private)

   - returns: instance
   */
  fileprivate init() {
    self.activeCount = 0
  }

  open class func shared() -> NetworkActivityIndicator {
    return sharedInstance
  }

  /**
   Count up `activeCount` and `networkActivityIndicatorVisible` change to true.
   */
  open func start() {
    syncQueue.sync { [unowned self] in
      self.activeCount += 1
    }
  }

  /**
   Count down `activeCount` and if count is zero, `networkActivityIndicatorVisible` change to false.
   */
  open func end() {
    syncQueue.sync { [unowned self] in
      self.activeCount -= 1
    }
  }

  /**
   Reset `activeCount` and `networkActivityIndicatorVisible` change to false.
   */
  open func endAll() {
    syncQueue.sync { [unowned self] in
      self.activeCount = 0
    }
  }

}
