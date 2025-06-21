//
//  VoucherViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 19/6/25.
//

import SwiftUI
import Combine

@MainActor
class VoucherViewModel: ObservableObject {
    @Published var availableVouchers: [Voucher] = []
    @Published var isLoading = false
    
    @Published var errorMessage: String? = nil
    
    @Published var selectedVoucher: Voucher? = nil
    
    private let voucherService: VoucherServicing
    
    var visibleVouchers: [Voucher] {
        availableVouchers.filter{ $0.isVisible }
    }
    
    var discountMultiplier: Double {
        guard let discountAmount = selectedVoucher?.discount else {
            return 1
        }
        
        return (100 - Double(discountAmount)) / 100
    }
    
    init(voucherService: VoucherServicing) {
        self.voucherService = voucherService
    }
    
    func loadInitialVouchers() async {
        guard !isLoading else { return }
        
        print("VoucherViewModel: Loading initial vouchers...")
        isLoading = true
        availableVouchers = []
        errorMessage = nil
        
        await fetchAllVouchers()
        isLoading = false
    }
    
    private func fetchAllVouchers() async {
        do {
            let response = try await voucherService.fetchVouchers()
            
            self.availableVouchers.append(contentsOf: response)
            
            print("VoucherViewModel: Loaded \(response.count) vouchers.")
            
        } catch let error as ApiClientError {
            print("❌ VoucherViewModel: API Error fetching vouchers - \(error)")
            self.errorMessage = "Failed to load vouchers. Please check connection."
        } catch {
            print("❌ VoucherViewModel: Unexpected error fetching vouchers - \(error)")
            self.errorMessage = "An unexpected error occurred while fetching vouchers."
        }
    }
    
    func applyVoucherWithCode(code: String) {
        if let voucher = availableVouchers.first(where: { $0.code == code}) {
            applyVoucher(voucher)
            print("VoucherViewModel: Voucher code '\(voucher.title)' found and applied!")
        } else {
            print("VoucherViewModel: Voucher code '\(code)' not valid.")
        }
    }
    
    func applyVoucher(_ voucher: Voucher) {
        print("VoucherViewModel: Voucher applied: \(voucher.title)")
        selectedVoucher = voucher
    }
    
    func clearSelectedVoucher() {
        selectedVoucher = nil
    }
    
    func clearLocalVoucherData() {
        print("VoucherViewModel: Clearing local voucher data.")
        self.availableVouchers = []
        self.selectedVoucher = nil
        self.isLoading = false
        self.errorMessage = nil
    }
}

