//
//  SceneDelegate.swift
//  UIKit001
//
//  Created by Alessandro Marzoli on 12/06/25.
//

import UIKit

class FirstViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "First"
    
    let button = UIButton(type: .system)
    button.setTitle("Push VC", for: .normal)
    button.titleLabel?.font = .boldSystemFont(ofSize: 18)
    button.addTarget(self, action: #selector(pushVC), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  @objc private func pushVC() {
    let vc = ThirdViewController()
    vc.hidesBottomBarWhenPushed = true // Not working on iOS 26
    navigationController?.pushViewController(vc, animated: true)
  }
}

class SecondViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Second"
  }
}

class ThirdViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Third"
    view.backgroundColor = .white
    
    let bottomBar = UIView()
    bottomBar.backgroundColor = .red
    bottomBar.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(bottomBar)
    
    NSLayoutConstraint.activate([
      bottomBar.heightAnchor.constraint(equalToConstant: 50),
      bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let tabBarController = UITabBarController()
    
    let vc1 = UINavigationController(rootViewController: FirstViewController())
    let vc2 = UINavigationController(rootViewController: SecondViewController())
    
    vc1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
    vc2.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart.fill"), tag: 1)
    
    
    tabBarController.viewControllers = [vc1, vc2]
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = tabBarController
    window?.makeKeyAndVisible()
  }
}
