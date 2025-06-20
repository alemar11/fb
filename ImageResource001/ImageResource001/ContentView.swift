//
//  ContentView.swift
//  ImageResource001
//
//  Created by Alessandro Marzoli on 04/08/23.
//

// Update Xcode 16: There is now a warning about images with the same name but not for namespaced folders

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      // Which smurf is loaded here? it seems the one from the "Folder" directory
      // but I wasn't able to find any documentation about which policy is applied
      Image.init(.smurf)
        .resizable()
        .aspectRatio(contentMode: .fit)

      // BUG: images inside namespaced folders aren't detected
      //          Image.init(.smurf1)
      //            .resizable()
      //            .aspectRatio(contentMode: .fit)
      // The workaround, for now, is to define the name programmatically
      Image.init(ImageResource(name: "NamespacedFolder/smurf1", bundle: .main))
        .resizable()
        .aspectRatio(contentMode: .fit)

      // ok
      Image.init(.smurf2)
        .resizable()
        .aspectRatio(contentMode: .fit)

      // ok
      Image.init(.smurf3)
        .resizable()
        .aspectRatio(contentMode: .fit)

    }
    .padding()
  }
}

#Preview {
  ContentView()
}
