//
//  DoctorViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 13/6/25.
//

import SwiftUI
import Combine

@MainActor
class DoctorViewModel: ObservableObject {
    @Published var doctors: [Doctor] = []
    @Published var isLoading = false
    
    @Published var isLoadingMore: Bool = false // Specific flag for loading subsequent pages
    @Published var hasMoreDoctors: Bool = true   // To know if we can fetch more
    @Published var errorMessage: String? = nil
    
    private var currentPage = 1
    private let defaultLimit = 10
    
    private let doctorService: DoctorServicing
    
    init(doctorService: DoctorServicing) {
        self.doctorService = doctorService
    }
    
    func loadInitialDoctors() async {
        guard !isLoading else { return }
        
        print("DoctorViewModel: Loading initial doctors...")
        isLoading = true
        doctors = []
        currentPage = 1
        hasMoreDoctors = true
        errorMessage = nil
        
        await fetchDoctorsForCurrentPage()
        isLoading = false
    }
    
    func loadMoreDoctors() async {
        // Only load more if not already loading more, and if there are more doctors
        guard !isLoadingMore && hasMoreDoctors && !isLoading else {
            if isLoading { print("DoctorViewModel: Initial load in progress, skipping loadMore.") }
            if isLoadingMore { print("DoctorViewModel: Already loading more doctors.") }
            if !hasMoreDoctors { print("DoctorViewModel: No more doctors to load.") }
            return
        }
        
        print("DoctorViewModel: Loading more doctors, current page before fetch: \(currentPage)")
        isLoadingMore = true
        errorMessage = nil
        
        await fetchDoctorsForCurrentPage()
        isLoadingMore = false
    }
    
    private func fetchDoctorsForCurrentPage() async {
        do {
            // Assuming your DoctorService.fetchDoctors expects 1-indexed page
            let response = try await doctorService.fetchDoctors(page: currentPage, limit: defaultLimit)
            
            // Append new doctors to the existing list
            self.doctors.append(contentsOf: response.doctors)
            
            // Update pagination state
            // Assuming response includes totalPages or similar info
            // If response.totalPages is 0-indexed, adjust comparison
            if let totalPages = response.totalPages {
                self.hasMoreDoctors = currentPage < totalPages
            } else {
                self.hasMoreDoctors = !response.doctors.isEmpty
            }
            
            if self.hasMoreDoctors {
                self.currentPage += 1 // Increment for the *next* potential fetch
            }
            print("DoctorViewModel: Loaded \(response.doctors.count) doctors. Total now: \(self.doctors.count). HasMore: \(self.hasMoreDoctors). Next page to fetch: \(self.currentPage)")
            
        } catch let error as ApiClientError { // Assuming ApiClientError exists
            print("❌ DoctorViewModel: API Error fetching doctors - \(error)")
            self.errorMessage = "Failed to load doctors. Please check connection."
            self.hasMoreDoctors = false // Stop trying on API error
        } catch {
            print("❌ DoctorViewModel: Unexpected error fetching doctors - \(error)")
            self.errorMessage = "An unexpected error occurred while fetching doctors."
            self.hasMoreDoctors = false // Stop trying on other errors
        }
    }
    
    // Call this from ContentView or App struct when user signs out
    func clearLocalDoctorData() {
        print("DoctorViewModel: Clearing local doctor data.")
        self.doctors = []
        self.currentPage = 1
        self.hasMoreDoctors = true
        self.isLoading = false
        self.isLoadingMore = false
        self.errorMessage = nil
    }
}
