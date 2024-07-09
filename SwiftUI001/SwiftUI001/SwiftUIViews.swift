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
  
  @State private var placement: SearchFieldPlacement = .navigationBarDrawer(displayMode: .always)
  @State private var searchText: String = ""
  @State private var loaded = false
  var body: some View {
    Group {
      if loaded {
        List {
          ForEach(items, id: \.self) { item in
            Text("\(item)")
          }
        }
        .listStyle(.plain)
        .navigationTitle("Search Page")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: placement, prompt: "Search")
        .transition(.slide)
        .refreshable {
          do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
          } catch {
            
          }
        }
      }
    }
    .task {
      loaded = true
    }
    .transaction(value: loaded) { transaction in
      transaction.animation = .interactiveSpring()
    }
  }
}

