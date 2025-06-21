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
    
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreDoctors: Bool = true
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
            let response = try await doctorService.fetchDoctors(page: currentPage, limit: defaultLimit)
            
            self.doctors.append(contentsOf: response.doctors)
            
            if let totalPages = response.totalPages {
                self.hasMoreDoctors = currentPage < totalPages
            } else {
                self.hasMoreDoctors = !response.doctors.isEmpty
            }
            
            if self.hasMoreDoctors {
                self.currentPage += 1
            }
            print("DoctorViewModel: Loaded \(response.doctors.count) doctors. Total now: \(self.doctors.count). HasMore: \(self.hasMoreDoctors). Next page to fetch: \(self.currentPage)")
            
        } catch let error as ApiClientError {
            print("❌ DoctorViewModel: API Error fetching doctors - \(error)")
            self.errorMessage = "Failed to load doctors. Please check connection."
            self.hasMoreDoctors = false
        } catch {
            print("❌ DoctorViewModel: Unexpected error fetching doctors - \(error)")
            self.errorMessage = "An unexpected error occurred while fetching doctors."
            self.hasMoreDoctors = false
        }
    }
    
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
