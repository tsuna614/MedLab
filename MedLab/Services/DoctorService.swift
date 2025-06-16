//
//  DoctorService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 13/6/25.
//

import Foundation

struct DoctorResponse: Codable {
    let total: Int?
    let totalPages: Int?
    let currentPage: Int?
    let doctors: [Doctor]
}

protocol DoctorServicing {
    func fetchDoctors(
        page: Int?,
        limit: Int?,
    ) async throws -> DoctorResponse
}

class DoctorService: DoctorServicing, ObservableObject {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func fetchDoctors(page: Int? = nil, limit: Int? = nil) async throws -> DoctorResponse {
        return try await apiClient.request(
            endpoint: .getDoctors(page: page, limit: limit),
            body: Optional<EmptyBody>.none,
            responseType: DoctorResponse.self
        )
    }
}
