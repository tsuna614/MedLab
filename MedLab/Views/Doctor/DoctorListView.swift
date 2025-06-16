//
//  DoctorListView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 14/6/25.
//

import SwiftUI

struct DoctorListView: View {
    // Use @StateObject if this view owns the ViewModel,
    // or @EnvironmentObject if it's provided by an ancestor (e.g., if this
    // is a tab in MainTabView and DoctorViewModel is created in ContentView/MainTabView).
    // For this example, assuming DoctorListView creates its own for simplicity of this file.
    // In a real app, consider where this VM's lifecycle should be managed.
    @StateObject private var viewModel: DoctorViewModel

    // Inject the DoctorService when creating this view
    init() {
        let doctorServiceInstance = DoctorService(apiClient: ApiClient(baseURLString: base_url))
        _viewModel = StateObject(wrappedValue: DoctorViewModel(doctorService: doctorServiceInstance))
    }

    var body: some View {
        // If this view is part of a larger navigation structure (e.g., a tab),
        // the NavigationStack might be provided by a parent.
        // If it's standalone or the root of its navigation, include it here.
        NavigationStack {
            ZStack { // For overlaying ProgressView during initial load
                ScrollView {
                    // Main content: Loading, Empty, Error, or Doctor List
                    contentView
                }
                // Optional: A more global error display if needed
                // if let error = viewModel.errorMessage { ErrorBannerView(message: error) }
            }
            .navigationTitle("Find a Doctor")
            // .navigationBarTitleDisplayMode(.inline) // Optional
            .toolbar {
                // Example: Add a filter button or other actions
                // ToolbarItem(placement: .navigationBarTrailing) {
                //     Button { print("Filter tapped") } label: { Image(systemName: "slider.horizontal.3") }
                // }
            }
            .onAppear {
                // Load initial doctors if the list is empty and not already loading
                if viewModel.doctors.isEmpty && !viewModel.isLoading {
                    Task {
                        await viewModel.loadInitialDoctors()
                    }
                }
            }
            // Alternative: Use .task for initial load tied to view lifecycle
            // .task {
            //    if viewModel.doctors.isEmpty { await viewModel.loadInitialDoctors() }
            // }
        }
    }

    // Extracted content view logic
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.doctors.isEmpty {
            // Initial loading state
            ProgressView("Loading doctors...")
                .padding(.top, 50) // Give some space
        } else if let errorMessage = viewModel.errorMessage, viewModel.doctors.isEmpty {
            // Error state when no doctors are loaded
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.loadInitialDoctors() } // Retry action
            }
        } else if viewModel.doctors.isEmpty {
            // Empty state (after successful load but no results)
            EmptyStateView(message: "No doctors found matching your criteria.")
        } else {
            // Doctor list with "load more" functionality
            doctorListWithPagination
        }
    }

    private var doctorListWithPagination: some View {
        LazyVStack(spacing: 15) {
            ForEach(viewModel.doctors) { doctor in
                NavigationLink {
                    DoctorDetailView(doctor: doctor)
                } label: {
                    DoctorCardView(doctor: doctor)
                }
                .buttonStyle(PlainButtonStyle()) // To make the whole card tappable
            }

            // "Load More" indicator / trigger
            if viewModel.isLoadingMore {
                ProgressView()
                    .padding()
            } else if viewModel.hasMoreDoctors {
                // Invisible element at the end of the list to trigger loading more
                Color.clear
                    .frame(height: 50)
                    .onAppear {
                        // Trigger load more when this element appears
                        Task {
                            await viewModel.loadMoreDoctors()
                        }
                    }
            } else if !viewModel.doctors.isEmpty {
                // No more doctors to load
                Text("You've reached the end.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding() // Padding for the LazyVStack
    }
}

// --- Helper Subviews for DoctorListView ---

struct DoctorCardView: View {
    let doctor: Doctor

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: URL(string: doctor.profileImageUrl ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else if phase.error != nil {
                    Image(systemName: "person.crop.circle.fill.badge.exclamationmark") // Error placeholder
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                        .frame(width: 80, height: 80)

                } else {
                    Image(systemName: "person.crop.circle.fill") // Default placeholder
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 80, height: 80)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(doctor.fullName)
                    .font(.headline)
                Text("Specialty: \(doctor.medicalSpecialty)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
//                if let clinic = doctor.clinicName {
//                    Text(clinic)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
                Text("\(doctor.yearsOfExperience) years experience")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
//                if let rating = doctor.averageRating {
//                    HStack {
//                        Image(systemName: "star.fill")
//                            .foregroundColor(.yellow)
//                        Text(String(format: "%.1f", rating))
//                    }
//                    .font(.caption)
//                }
            }
            Spacer() // Pushes content to the left
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(radius: 2, x: 0, y: 1)
    }
}

struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error")
                .font(.title2)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let message: String
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "person.3.sequence.fill") // Or another suitable icon
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text(message)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

class MockDoctorService: DoctorServicing {
    // Example Mock
    func fetchDoctors(page: Int?, limit: Int?) async throws -> DoctorResponse {
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate delay
        let allDoctors = Doctor.sampleDoctors // Use your dummy data
        
        let p = page ?? 1
        let l = limit ?? 10
        let totalPagesDouble = ceil(Double(allDoctors.count) / Double(l))
        let totalPages = Int(totalPagesDouble)
        
        let startIndex = (p - 1) * l // Assuming page is 1-indexed for this mock calculation
        if startIndex >= allDoctors.count {
            return DoctorResponse(total: allDoctors.count, totalPages: totalPages, currentPage: p, doctors: [])
        }
        let endIndex = min(startIndex + l, allDoctors.count)
        
        return DoctorResponse(
            total: allDoctors.count,
            totalPages: totalPages,
            currentPage: p,
            doctors: Array(allDoctors[startIndex..<endIndex]),
        )
    }
}

//// Dummy DoctorListResponse for preview service
//struct DoctorListResponse: Codable {
//    let doctors: [Doctor]
//    let totalPages: Int?
//    let currentPage: Int?
//    let totalItems: Int? // For total count
//}
//
//// Helper extension for ceiling division
//extension Double {
//    func ceil() -> Double {
//        return Foundation.ceil(self)
//    }
//     func toInt() -> Int {
//        return Int(self)
//    }
//}
//
//
//#Preview {
//    // DoctorListView needs DoctorService injected
//    let mockService = MockDoctorService()
//    return NavigationView { // Often part of a navigation flow
//        DoctorListView(doctorService: mockService)
//            // Add other environment objects if DoctorDetailView or other subviews need them
//            // .environmentObject(AppViewModel())
//    }
//}
