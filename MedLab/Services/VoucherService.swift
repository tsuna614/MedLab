//
//  VoucherService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 19/6/25.
//

import Foundation

//struct VoucherResponse: Codable {
//    let total: Int?
//    let totalPages: Int?
//    let currentPage: Int?
//    let vouchers: [Voucher]
//}

protocol VoucherServicing {
    func fetchVouchers() async throws -> [Voucher]
}

class VoucherService: VoucherServicing, ObservableObject {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func fetchVouchers() async throws -> [Voucher] {
        return try await apiClient.request(
            endpoint: .getVouchers,
            body: Optional<EmptyBody>.none,
            responseType: [Voucher].self
        )
    }
}
