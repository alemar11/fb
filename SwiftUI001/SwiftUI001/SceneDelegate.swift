//
//  SceneDelegate.swift
//  SwiftUI001
//
//  Created by Alessandro Marzoli on 27/06/24.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    let navigationController = UINavigationController()
    let contentView = RootView(navController: navigationController) { navController in
      navController.pushViewController(UIHostingController(rootView: SearchView().transition(.slide)), animated: false)
    }
    let firstController = UIHostingController(rootView: contentView)
    navigationController.setViewControllers([firstController], animated: false)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {}
  
  func sceneDidBecomeActive(_ scene: UIScene) {}
  
  func sceneWillResignActive(_ scene: UIScene) {}
  
  func sceneWillEnterForeground(_ scene: UIScene) {}
  
  func sceneDidEnterBackground(_ scene: UIScene) {}
}
