//
//  ImagePicker.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/5/25.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        print("ImagePicker: makeUIViewController with sourceType: \(sourceType == .camera ? "Camera" : "Photo Library")")
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Update sourceType if it changes while picker is visible (less common)
        if uiViewController.sourceType != sourceType {
            uiViewController.sourceType = sourceType
            print("ImagePicker: updateUIViewController updated sourceType to: \(sourceType == .camera ? "Camera" : "Photo Library")")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                print("ImagePicker.Coordinator: Image picked/captured.")
                parent.selectedImage = image
            } else {
                print("ImagePicker.Coordinator: No image found in info dictionary.")
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("ImagePicker.Coordinator: Picker cancelled.")
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
