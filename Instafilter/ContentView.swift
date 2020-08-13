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
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    @State private var processedImage: UIImage?
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        return NavigationView {
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
                    Slider(value: intensity)
                }
                .padding(.vertical)
                HStack {
                    Button("Change Filter", action: {
                        self.showingFilterSheet = true
                    })
                    Spacer()
                    Button("Save", action: {
                        guard let processedImage = self.processedImage else { return }
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    })
                    .disabled(image == nil)
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
            .actionSheet(isPresented: $showingFilterSheet, content: {
                ActionSheet(
                    title: Text("Select a filter"),
                    buttons: [
                        .default(
                            Text("Crystallise"),
                            action: { self.setFilter(CIFilter.crystallize()) }
                        ),
                        .default(
                            Text("Edges"),
                            action: { self.setFilter(CIFilter.edges()) }
                        ),
                        .default(
                            Text("Gaussian Blur"),
                            action: { self.setFilter(CIFilter.gaussianBlur()) }
                        ),
                        .default(
                            Text("Monochrome"),
                            action: { self.setFilter(CIFilter.colorMonochrome()) }
                        ),
                        .default(
                            Text("Pixellate"),
                            action: { self.setFilter(CIFilter.pixellate()) }
                        ),
                        .default(
                            Text("Sepia Tone"),
                            action: { self.setFilter(CIFilter.sepiaTone()) }
                        ),
                        .default(
                            Text("Unsharp Mark"),
                            action: { self.setFilter(CIFilter.unsharpMask()) }
                        ),
                        .default(
                            Text("Vignette"),
                            action: { self.setFilter(CIFilter.vignette()) }
                        ),
                        // Diable intensity slider before allowing:
//                        .default(
//                            Text("Chrome"),
//                            action: { self.setFilter(CIFilter.photoEffectChrome()) }
//                        ),
//                        .default(
//                            Text("Dot Screen"),
//                            action: { self.setFilter(CIFilter.dotScreen()) }
//                        ),
//                        .default(
//                            Text("Fade"),
//                            action: { self.setFilter(CIFilter.photoEffectFade()) }
//                        ),
//                        .default(
//                            Text("False Color"),
//                            action: { self.setFilter(CIFilter.falseColor()) }
//                        ),
//                        .default(
//                            Text("Kaleidoscope"),
//                            action: { self.setFilter(CIFilter.kaleidoscope()) }
//                        ),
//                        .default(
//                            Text("Mono"),
//                            action: { self.setFilter(CIFilter.photoEffectMono()) }
//                        ),
                        .cancel()
                    ]
                )
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
