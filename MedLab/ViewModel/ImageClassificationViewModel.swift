////
////  ImageClassificationViewModel.swift
////  MedLab
////
////  Created by Khanh Nguyen Quoc on 20/5/25.
////
//
//import SwiftUI
//import Vision // For VNCoreMLRequest, VNImageRequestHandler
//import CoreML   // For the model itself and MLModelConfiguration
//
//@MainActor // Ensure UI updates happen on the main thread
//class ImageClassificationViewModel: ObservableObject {
//
//    // MARK: - Published Properties for UI
//    @Published var selectedImage: UIImage?
//    @Published var classificationResult: String? // To store the top class label
//    @Published var confidence: Double?         // To store the confidence of the top result
//    @Published var isProcessing: Bool = false
//    @Published var errorMessage: String? = nil
//
//    // MARK: - Core ML Model
//    private var visionModel: VNCoreMLModel?
//    private let modelInputSize = CGSize(width: 299, height: 299) // <<< ADJUST THIS to your model's expected input size
//
//    // MARK: - Initializer
//    init() {
//        loadModel()
//    }
//
//    private func loadModel() {
//        do {
//            let modelConfig = MLModelConfiguration()
//            // *** REPLACE 'MedicineBoxClassifier1_0' with the actual class name Xcode generated ***
//            //     (Check by selecting the .mlmodel file in Xcode)
//            let coreMLModel = try MedicineBoxClassifier(configuration: modelConfig)
//            visionModel = try VNCoreMLModel(for: coreMLModel.model)
//            print("ImageClassificationViewModel: Core ML model loaded successfully.")
//        } catch {
//            print("❌ ImageClassificationViewModel: Failed to load Core ML model: \(error)")
//            errorMessage = "Error loading classification model: \(error.localizedDescription)"
//        }
//    }
//
//    // MARK: - Classification Logic
//    func classifyImage(_ image: UIImage) {
//        guard let visionModel = visionModel else {
//            errorMessage = "Classification model is not loaded."
//            print("❌ \(errorMessage!)")
//            return
//        }
//        guard !isProcessing else {
//            print("ℹ️ Already processing an image.")
//            return
//        }
//
//        self.selectedImage = image // Store for display
//        isProcessing = true
//        errorMessage = nil
//        classificationResult = nil
//        confidence = nil
//
//        Task(priority: .userInitiated) { // Perform on a background thread
//            // 1. Prepare the image (resize and convert to CVPixelBuffer)
//            guard let pixelBuffer = image.toPixelBuffer(size: modelInputSize) else {
//                // Ensure UI updates are on the main thread
//                await MainActor.run {
//                    self.errorMessage = "Failed to convert image to pixel buffer."
//                    self.isProcessing = false
//                }
//                print("❌ \(self.errorMessage!)")
//                return
//            }
////            guard let cgImage = image.cgImage else { // Get CGImage directly
////                await MainActor.run {
////                    self.errorMessage = "Failed to get CGImage from UIImage."
////                    self.isProcessing = false
////                }
////                return
////            }
//
//            // 2. Create a VNCoreMLRequest
//            let request = VNCoreMLRequest(model: visionModel) { (finishedRequest, error) in
//                // This completion handler is called on a background thread by default.
//                // Switch back to the main thread to update @Published properties.
//                Task { @MainActor in
//                    self.isProcessing = false // Processing finished
//
//                    if let error = error {
//                        print("❌ Vision request failed: \(error.localizedDescription)")
//                        self.errorMessage = "Image classification failed: \(error.localizedDescription)"
//                        return
//                    }
//
//                    // 3. Process the results
//                    guard let results = finishedRequest.results as? [VNClassificationObservation] else {
//                        print("❌ Could not cast Vision request results to VNClassificationObservation.")
//                        self.errorMessage = "Could not process classification results."
//                        return
//                    }
//
//                    if let firstResult = results.first { // Get the top classification
//                        self.classificationResult = firstResult.identifier
//                        self.confidence = Double(firstResult.confidence)
//                        print("✅ Classification: \(self.classificationResult ?? "N/A") (Confidence: \(self.confidence ?? 0.0))")
//                    } else {
//                        print("ℹ️ No classification results found.")
//                        self.classificationResult = "No result"
//                        self.confidence = 0.0
//                    }
//                }
//            }
//
//            // 4. Create a VNImageRequestHandler
//            //    Ensure you use the correct image orientation
//            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: image.cgImageOrientation, options: [:])
//            
////            request.imageCropAndScaleOption = .scaleFit // Or .centerCrop or .scaleFill
////            
////            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
//
//            // 5. Perform the request
//            do {
//                try handler.perform([request])
//            } catch {
//                // Ensure UI updates are on the main thread
//                await MainActor.run {
//                    print("❌ Failed to perform Vision request: \(error.localizedDescription)")
//                    self.errorMessage = "Error during image analysis: \(error.localizedDescription)"
//                    self.isProcessing = false
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UIImage Extension for CVPixelBuffer Conversion
//// (You might need to refine this helper based on your model's exact pixel format needs)
//extension UIImage {
//    func toPixelBuffer(size: CGSize) -> CVPixelBuffer? {
//        let width = Int(size.width)
//        let height = Int(size.height)
//
//        // 1. Resize the image
//        UIGraphicsBeginImageContextWithOptions(size, true, self.scale)
//        self.draw(in: CGRect(origin: .zero, size: size))
//        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
//            UIGraphicsEndImageContext()
//            return nil
//        }
//        UIGraphicsEndImageContext()
//
//        // 2. Convert to CVPixelBuffer
//        guard let cgImage = resizedImage.cgImage else {
//            return nil
//        }
//
//        let attrs = [
//            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
//            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
//        ] as CFDictionary
//        var pixelBuffer: CVPixelBuffer?
//        let status = CVPixelBufferCreate(kCFAllocatorDefault,
//                                         width,
//                                         height,
//                                         kCVPixelFormatType_32ARGB, // Common format, check your model's spec
//                                         attrs,
//                                         &pixelBuffer)
//
//        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
//            return nil
//        }
//
//        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
//
//        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//        guard let context = CGContext(data: pixelData,
//                                      width: width,
//                                      height: height,
//                                      bitsPerComponent: 8,
//                                      bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
//                                      space: rgbColorSpace,
//                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) // Or .premultipliedFirst
//        else {
//            CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//            return nil
//        }
//
//        context.translateBy(x: 0, y: CGFloat(height))
//        context.scaleBy(x: 1.0, y: -1.0) // Flip context to draw image upright
//
//        UIGraphicsPushContext(context)
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//        UIGraphicsPopContext()
//        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//
//        return unwrappedPixelBuffer
//    }
//
//    // Helper to get CGImage orientation from UIImage orientation
//    var cgImageOrientation: CGImagePropertyOrientation {
//        switch self.imageOrientation {
//            case .up: return .up
//            case .down: return .down
//            case .left: return .left
//            case .right: return .right
//            case .upMirrored: return .upMirrored
//            case .downMirrored: return .downMirrored
//            case .leftMirrored: return .leftMirrored
//            case .rightMirrored: return .rightMirrored
//            @unknown default: return .up
//        }
//    }
//}


import SwiftUI
import Vision
import CoreML

@MainActor
class ImageClassificationViewModel: ObservableObject {
    @Published var selectedImage: UIImage? {
        didSet {
            if let newImage = selectedImage, newImage !== oldValue {
                print("ImageClassificationViewModel: selectedImage changed, starting classification.")
                classifyImage(newImage)
            } else if selectedImage == nil && oldValue != nil {
                print("ImageClassificationViewModel: selectedImage cleared.")
                classificationResult = nil
                confidence = nil
                errorMessage = nil
            }
        }
    }
    @Published var classificationResult: String?
    @Published var confidence: Double?
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String? = nil

    private var visionModel: VNCoreMLModel?
    private let modelInputWidth = 299
    private let modelInputHeight = 299

    init() {
        loadModel()
    }

    private func loadModel() {
        do {
            let modelConfig = MLModelConfiguration()
            #if targetEnvironment(simulator)
                print("ℹ️ Running on Simulator: Forcing Core ML model to use CPU only.")
                modelConfig.computeUnits = .cpuOnly
            #else
                print("ℹ️ Running on Device: Allowing Core ML to use all compute units.")
                modelConfig.computeUnits = .all
            #endif
            let coreMLModel = try MedicineBoxClassifier(configuration: modelConfig) // Replace with your model class
            visionModel = try VNCoreMLModel(for: coreMLModel.model)
            print("ImageClassificationViewModel: Core ML model loaded successfully (Compute Units: \(modelConfig.computeUnits.description)).")
        } catch {
            let loadError = "Failed to load Core ML model: \(error.localizedDescription)"
            print("❌ ImageClassificationViewModel: \(loadError)")
            errorMessage = loadError
        }
    }

    private func classifyImage(_ image: UIImage) {
        guard let visionModel = self.visionModel else {
            errorMessage = "Classification model is not loaded."
            print("❌ \(errorMessage!)")
            return
        }
        guard !isProcessing else {
            print("ℹ️ ImageClassificationViewModel: Already processing an image.")
            return
        }

        isProcessing = true
        errorMessage = nil
        classificationResult = nil
        confidence = nil
        print("ImageClassificationViewModel: Classifying image...")

        Task(priority: .userInitiated) {
            guard let pixelBuffer = image.pixelBuffer(width: modelInputWidth, height: modelInputHeight) else {
                await MainActor.run {
                    self.errorMessage = "Failed to convert image to pixel buffer."
                    self.isProcessing = false
                }
                print("❌ \(self.errorMessage!)")
                return
            }
            print("ℹ️ ImageClassificationViewModel: Pixel buffer created successfully.")

            let request = VNCoreMLRequest(model: visionModel) { (finishedRequest, error) in
                Task { @MainActor in
                    self.isProcessing = false
                    if let error = error {
                        let reqError = "Vision request failed: \(error.localizedDescription)"
                        print("❌ ImageClassificationViewModel: \(reqError)")
                        self.errorMessage = reqError
                        return
                    }
                    guard let results = finishedRequest.results as? [VNClassificationObservation] else {
                        let castError = "Could not cast Vision results."
                        print("❌ ImageClassificationViewModel: \(castError)")
                        self.errorMessage = castError
                        return
                    }
                    if let firstResult = results.first {
                        self.classificationResult = firstResult.identifier
                        self.confidence = Double(firstResult.confidence)
                        print("✅ Classification: \(self.classificationResult ?? "N/A") (Conf: \(self.confidence ?? 0.0))")
                    } else {
                        print("ℹ️ No classification results found.")
                        self.classificationResult = "No result"
                        self.confidence = 0.0
                    }
                }
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: image.cgImageOrientation, options: [:])
            print("ℹ️ ImageClassificationViewModel: VNImageRequestHandler created.")

            do {
                print("ℹ️ ImageClassificationViewModel: Performing Vision request...")
                try handler.perform([request])
                print("ℹ️ ImageClassificationViewModel: Vision request performed.")
            } catch {
                await MainActor.run {
                    let performError = "Failed to perform Vision request: \(error.localizedDescription)"
                    print("❌ ImageClassificationViewModel: \(performError)")
                    self.errorMessage = performError
                    self.isProcessing = false
                }
            }
        }
    }
}

extension MLComputeUnits { // Helper for logging
    var description: String {
        switch self {
        case .cpuOnly: return "CPU Only"
        case .cpuAndGPU: return "CPU and GPU"
        case .all: return "All (CPU, GPU, Neural Engine)"
        @unknown default: return "Unknown"
        }
    }
}

extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let imageSize = CGSize(width: width, height: height)
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!,
        ]
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            print("Error: CVPixelBufferCreate failed with status \(status)")
            return nil
        }
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0)) }
        guard let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer) else {
            print("Error: Could not get pixel buffer base address")
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(imageSize, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: imageSize))
        guard let resizedCGImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            UIGraphicsEndImageContext()
            print("Error: Could not resize image in UIGraphics context")
            return nil
        }
        UIGraphicsEndImageContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else {
            print("Error: Could not create CGContext")
            return nil
        }
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(resizedCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return unwrappedPixelBuffer
    }

    var cgImageOrientation: CGImagePropertyOrientation {
        switch self.imageOrientation {
            case .up: return .up
            case .down: return .down
            case .left: return .left
            case .right: return .right
            case .upMirrored: return .upMirrored
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .rightMirrored: return .rightMirrored
            @unknown default: return .up
        }
    }
}
