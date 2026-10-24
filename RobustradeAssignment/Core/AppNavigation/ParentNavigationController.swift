//
//  ParentNavigationController.swift
//  RobustradeAssignment
//
//  Created by Mahendra on 23/10/26.
//
import UIKit

class ParentNavigationController: UINavigationController {
    
    // MARK: - Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()
           setupGlobalAppearance()
       }
       
       // MARK: - Setup & Customisation
       private func setupGlobalAppearance() {
           // Configure standard background colors
           view.backgroundColor = .systemBackground
           
           // Define navigation bar styling (iOS 13+ modern API layout)
           let appearance = UINavigationBarAppearance()
           appearance.configureWithOpaqueBackground()
           appearance.backgroundColor = .systemBackground
           appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
           appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
           
           // Apply smooth back button configuration across all children
           let backButtonAppearance = UIBarButtonItemAppearance()
           backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear] // Hides text, leaves just the arrow
           appearance.backButtonAppearance = backButtonAppearance
           
           // Enforce appearance rules globally on this controller instance
           navigationBar.standardAppearance = appearance
           navigationBar.scrollEdgeAppearance = appearance
           navigationBar.compactAppearance = appearance
           
           // Tint color controls buttons and icons (like the back arrow)
           navigationBar.tintColor = .systemBlue
       }
       
       // MARK: - Device Configuration Controls
       // Control orientation behavior globally across the stack
       override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
           return topViewController?.supportedInterfaceOrientations ?? .portrait
       }
       
       // Pass status bar preferences down to the visible screen
       override var preferredStatusBarStyle: UIStatusBarStyle {
           return topViewController?.preferredStatusBarStyle ?? .default
       }
   }
