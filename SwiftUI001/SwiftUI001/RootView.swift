//
//  ViewController.swift
//  SwiftUI001
//
//  Created by Alessandro Marzoli on 27/06/24.
//

import UIKit
import SwiftUI

struct RootView: View {
  var navController: UINavigationController
  var didTapButton: (UINavigationController) -> ()
  
  var body: some View {
    Button {
      didTapButton(navController)
    } label: {
      Text("Tap this to show broken search bar animation")
    }
    .navigationTitle("First Page")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct SearchView: View {
  let items: [Int] = {
    (0...100).map {$0}
  }()
  
  @State var searchText: String = ""
  
  var body: some View {
    List {
      ForEach(items, id: \.self) { item in
        Text("\(item)")
      }
    }
    .listStyle(.plain)
    .navigationTitle("Search Page")
    .navigationBarTitleDisplayMode(.inline)
    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
    .transition(.slide)
  }
}
