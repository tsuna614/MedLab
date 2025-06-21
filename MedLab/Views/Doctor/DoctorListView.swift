//
//  DoctorListView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 14/6/25.
//

import SwiftUI

struct DoctorListView: View {
//    @EnvironmentObject var doctorService: DoctorService
    @StateObject private var viewModel: DoctorViewModel

    init() {
        let doctorServiceInstance = DoctorService(apiClient: ApiClient(baseURLString: base_url))
        _viewModel = StateObject(wrappedValue: DoctorViewModel(doctorService: doctorServiceInstance))
        //        let tempService = DoctorService(apiClient: ApiClient(baseURLString: "placeholder"))
        //        _viewModel = StateObject(wrappedValue: DoctorViewModel(doctorService: tempService))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    contentView
                }
            }
            .navigationTitle("Find a Doctor")
            .toolbar {
            }
            .onAppear {
//                if viewModel.doctorService !== self.doctorService {
//                    _viewModel = StateObject(wrappedValue: DoctorViewModel(doctorService: self.doctorService))
//                }
                if viewModel.doctors.isEmpty && !viewModel.isLoading {
                    Task {
                        await viewModel.loadInitialDoctors()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.doctors.isEmpty {
            ProgressView("Loading doctors...")
                .padding(.top, 50) // Give some space
        } else if let errorMessage = viewModel.errorMessage, viewModel.doctors.isEmpty {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.loadInitialDoctors() } // Retry action
            }
        } else if viewModel.doctors.isEmpty {
            EmptyStateView(message: "No doctors found matching your criteria.")
        } else {
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

            if viewModel.isLoadingMore {
                ProgressView()
                    .padding()
            } else if viewModel.hasMoreDoctors {
                Color.clear
                    .frame(height: 50)
                    .onAppear {
                        Task {
                            await viewModel.loadMoreDoctors()
                        }
                    }
            } else if !viewModel.doctors.isEmpty {
                Text("You've reached the end.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
    }
}


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
            Spacer()
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
