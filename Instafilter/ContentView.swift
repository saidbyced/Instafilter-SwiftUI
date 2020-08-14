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
    @State private var intensitySliderHidden = false
    @State private var filterIntensity = 0.5
    @State private var radiusSliderHidden = true
    @State private var filterRadius = 0.5
    @State private var scaleSliderHidden = true
    @State private var filterScale = 0.5
    
    @State private var inputImage: UIImage?
    @State private var showingImagePickerView = false
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var currentFilterName: String = "Sepia Tone"
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    @State private var processedImage: UIImage?
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        intensitySliderHidden = true
        radiusSliderHidden = true
        scaleSliderHidden = true
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
            intensitySliderHidden = false
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey)
            radiusSliderHidden = false
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey)
            scaleSliderHidden = false
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
        let radius = Binding<Double>(
            get: {
                self.filterRadius
            },
            set: {
                self.filterRadius = $0
                self.applyProcessing()
            }
        )
        let scale = Binding<Double>(
            get: {
                self.filterScale
            },
            set: {
                self.filterScale = $0
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
                    Button(currentFilterName, action: {
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
                .padding(.top, 10)
                .padding(.horizontal, 20)
                Divider()
                VStack {
                    HStack {
                        Text("Intensity")
                            .frame(minWidth: 70, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.trailing, 5)
                        Slider(value: intensity)
                            .padding(.trailing, 25)
                            .disabled(intensitySliderHidden)
                    }
                    HStack {
                        Text("Radius")
                            .frame(minWidth: 70, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.trailing, 5)
                        Slider(value: radius)
                            .padding(.trailing, 25)
                            .disabled(radiusSliderHidden)
                        
                    }
                    HStack {
                        Text("Scale")
                            .frame(minWidth: 70, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.trailing, 5)
                        Slider(value: scale)
                            .padding(.trailing, 25)
                            .disabled(scaleSliderHidden)
                    }
                }
                .padding(.bottom)
            }
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
                            action: {
                                self.setFilter(CIFilter.crystallize())
                                self.currentFilterName = "Crystallise"
                            }
                        ),
                        .default(
                            Text("Edges"),
                            action: {
                                self.setFilter(CIFilter.edges())
                                self.currentFilterName = "Edges"
                            }
                        ),
                        .default(
                            Text("Gaussian Blur"),
                            action: {
                                self.setFilter(CIFilter.gaussianBlur())
                                self.currentFilterName = "Gaussian Blur"
                            }
                        ),
                        .default(
                            Text("Monochrome"),
                            action: {
                                self.setFilter(CIFilter.colorMonochrome())
                                self.currentFilterName = "Monochrome"
                            }
                        ),
                        .default(
                            Text("Pixellate"),
                            action: {
                                self.setFilter(CIFilter.pixellate())
                                self.currentFilterName = "Pixellate"
                            }
                        ),
                        .default(
                            Text("Sepia Tone"),
                            action: {
                                self.setFilter(CIFilter.sepiaTone())
                                self.currentFilterName = "Sepia Tone"
                            }
                        ),
                        .default(
                            Text("Unsharp Mark"),
                            action: {
                                self.setFilter(CIFilter.unsharpMask())
                                self.currentFilterName = "Unsharp Mark"
                            }
                        ),
                        .default(
                            Text("Vignette"),
                            action: {
                                self.setFilter(CIFilter.vignette())
                                self.currentFilterName = "Vignette"
                            }
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
