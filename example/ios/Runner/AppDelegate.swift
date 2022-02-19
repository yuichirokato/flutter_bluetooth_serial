//
//  AppDelegate.swift
//  Runner
//
//  Created by Yuichiro Takahashi on 2022/02/19.
//  Copyright © 2022 The Chromium Authors. All rights reserved.
//

import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
