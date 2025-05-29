//
//  MedicineClassifierView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 20/5/25.
//

import SwiftUI
import PhotosUI // For PhotosPicker

struct MedicineClassifierView: View {
    @StateObject private var viewModel = ImageClassificationViewModel()

    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera

    var body: some View {
        VStack(spacing: 16) {
            Text("Medicine Box Classifier")
                .font(.largeTitle)
                .padding(.bottom)

            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Select or Take an Image")
                        .foregroundColor(.gray)
                        .offset(y: 60)
                }
                .frame(height: 300)
            }

            HStack(spacing: 20) {
                PhotosPicker(
                    selection: $photosPickerItem,
                    matching: .images
                ) {
                    Label("From Library", systemImage: "photo.on.rectangle.angled")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isProcessing)

                Button {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        self.imagePickerSourceType = .camera
                        self.showingImagePicker = true
                        print("MedicineClassifierView: Camera button tapped, showing picker for camera.")
                    } else {
                        viewModel.errorMessage = "Camera is not available on this device."
                        print("MedicineClassifierView: Camera not available.")
                    }
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isProcessing)
            }
            .padding(.top)
            .onChange(of: photosPickerItem) { oldValue, newValue in
                guard let item = newValue else {
                    print("MedicineClassifierView: PhotosPicker item is nil.")
                    // Optionally clear selected image if user deselects in PhotosPicker UI
                    // viewModel.selectedImage = nil
                    return
                }
                print("MedicineClassifierView: PhotosPicker item changed.")
                Task {
                    do {
                        if let data = try await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                print("MedicineClassifierView: Image loaded from PhotosPicker.")
                                viewModel.selectedImage = uiImage // This will trigger classify via didSet
                            } else {
                                print("MedicineClassifierView: Failed to create UIImage from PhotosPicker data.")
                                await MainActor.run { viewModel.errorMessage = "Could not load image data." }
                            }
                        } else {
                            print("MedicineClassifierView: No data loaded from PhotosPickerItem.")
                            await MainActor.run { viewModel.errorMessage = "No data found for selected item." }
                        }
                    } catch {
                        print("MedicineClassifierView: Error loading transferable from PhotosPicker: \(error)")
                        await MainActor.run { viewModel.errorMessage = "Error loading image: \(error.localizedDescription)" }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                
                ImagePicker(selectedImage: $viewModel.selectedImage, sourceType: self.imagePickerSourceType)
            }

            if viewModel.isProcessing {
                ProgressView("Classifying...")
                    .padding()
            }

            if let result = viewModel.classificationResult, let confidence = viewModel.confidence {
                VStack {
                    Text("Prediction:")
                        .font(.headline)
                    Text(result)
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Text("Confidence: \(String(format: "%.2f%%", confidence * 100))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }

            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Classify Medicine")
    }
}
