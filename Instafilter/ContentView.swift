//
//  ContentView.swift
//  Instafilter
//
//  Created by Chris Eadie on 04/08/2020.
//  Copyright © 2020 Chris Eadie Designs. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var inputImage: UIImage?
    @State private var showingImagePickerView = false
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePickerView = true
                }
                HStack {
                    Text("Intensity")
                    Slider(value: self.$filterIntensity)
                }
                .padding(.vertical)
                HStack {
                    Button("Change Filter", action: {
                        // TODO: Change filter
                    })
                    Spacer()
                    Button("Save", action: {
                        // TODO: Save the picture
                    })
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(
                isPresented: $showingImagePickerView,
                onDismiss: loadImage,
                content: {
                    ImagePicker(image: self.$inputImage)
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
