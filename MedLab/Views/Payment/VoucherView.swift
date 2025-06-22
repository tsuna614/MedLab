//
//  VoucherView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 19/6/25.
//

import SwiftUI


struct VoucherView: View {

    @State private var enteredCode: String = ""
    @Environment(\.dismiss) var dismiss
    
    @StateObject var voucherVM: VoucherViewModel
    @EnvironmentObject var snackbarViewModel: SnackBarViewModel
    @EnvironmentObject var appVM: AppViewModel

    private var filteredVouchers: [Voucher] {
        if enteredCode.isEmpty {
            return voucherVM.visibleVouchers
        }
        return voucherVM.visibleVouchers.filter {
            $0.code.lowercased().contains(enteredCode.lowercased()) ||
            $0.title.lowercased().contains(enteredCode.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    TextField("Enter voucher code", text: $enteredCode)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .autocapitalization(.allCharacters)

                    Button("Apply") {
                        applyHiddenCode()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(enteredCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()

                Divider()

                if voucherVM.visibleVouchers.isEmpty && enteredCode.isEmpty {
                    Spacer()
                    Text("No vouchers available at the moment.")
                        .foregroundColor(.secondary)
                    Spacer()
                } else if !filteredVouchers.isEmpty {
                    List {
                        Section(header: Text("Available Vouchers").font(.headline)) {
                            ForEach(filteredVouchers) { voucher in
                                VoucherRow(voucher: voucher)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
//                                        let isVoucherInvalid = voucher.isExpired || appVM.user?.usedVouchersCode?.contains(voucher.code) == true
                                        let isVoucherUsed = appVM.user?.usedVouchersCode.contains(voucher.code) ?? false
                                        let isVoucherInvalid = voucher.isExpired || isVoucherUsed

                                        
                                        if !isVoucherInvalid {
                                            selectVoucher(voucher)
                                        } else {
                                            snackbarViewModel.showSnackbar(message: "\(voucher.code) is invalid to use")
                                        }
                                    }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else if !enteredCode.isEmpty && filteredVouchers.isEmpty {
                    Spacer()
                    Text("No visible vouchers match '\(enteredCode)'.\nTap 'Apply' if it's a hidden code.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("Select Voucher")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if voucherVM.availableVouchers.isEmpty && !voucherVM.isLoading {
                    Task {
                        await voucherVM.loadInitialVouchers()
                    }
                }
            }
        }
        
    }

    private func selectVoucher(_ voucher: Voucher) {
        print("Voucher selected from list: \(voucher.code) - \(voucher.title)")
        voucherVM.applyVoucher(voucher)
        snackbarViewModel.showSnackbar(message: "Voucher \(voucher.code) applied")
        dismiss()
    }

    private func applyHiddenCode() {
        let codeToApply = enteredCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !codeToApply.isEmpty else { return }

        print("Attempting to apply hidden voucher code: \(codeToApply)")
        voucherVM.applyVoucherWithCode(code: codeToApply)
        snackbarViewModel.showSnackbar(message: "Voucher \(codeToApply) applied")
        dismiss()
    }
}

struct VoucherRow: View {
    let voucher: Voucher
    @EnvironmentObject var appVM: AppViewModel

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

//    private var formattedExpiryDate: String {
//        let isoFormatter = ISO8601DateFormatter()
//        if let date = isoFormatter.date(from: voucher.expiryDate) {
//            return Self.dateFormatter.string(from: date)
//        }
//        return voucher.expiryDate
//    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(voucher.title)
                    .font(.headline)
                Text(voucher.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text("Code: \(voucher.code)")
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text("\(voucher.discount)% OFF")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.green)
                
                (
                    Text("Expires: ") +
                    Text(voucher.expiryDate, style: .date)
                )
                .font(.caption)
                .foregroundColor(.gray)
                
                if voucher.isExpired {
                    Text("Expired")
                        .font(.footnote)
                        .foregroundColor(.red)
                } else if appVM.user?.usedVouchersCode.contains(voucher.code) == true {
                    Text("Already Used")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}


//let sampleVouchers: [Voucher] = [
//    Voucher(id: "1", title: "Grand Opening Discount", description: "Get 20% off your first order! Limited time offer.", code: "WELCOME20", discount: 20, expiryDate: "2025-12-31T23:59:59Z"),
//    Voucher(id: "2", title: "Summer Sale Special", description: "15% off on all beauty care products. Enjoy the sun!", code: "SUMMER15", discount: 15, expiryDate: "2025-08-31T23:59:59Z"),
//    Voucher(id: "3", title: "Loyalty Reward", description: "Thank you for being a loyal customer! Here's 10% off.", code: "LOYAL10", discount: 10, expiryDate: "2026-01-15T23:59:59Z"),
//    Voucher(id: "4", title: "Flash Deal (Hidden)", description: "A special hidden deal just for you!", code: "SECRET50", discount: 50, expiryDate: "2025-06-01T23:59:59Z") // Example hidden
//]

//#Preview {
////    VoucherView(
////        availableVouchers: Array(sampleVouchers.prefix(3)),
////        onVoucherSelected: { voucher in
////            print("Preview: Voucher selected - \(voucher.code)")
////        },
////        onHiddenVoucherApplied: { code in
////            print("Preview: Hidden code applied - \(code)")
////            // Simulate finding the hidden voucher
////            if let hiddenVoucher = sampleVouchers.first(where: { $0.code == code && code == "SECRET50"}) {
////                 print("Preview: Hidden voucher '\(hiddenVoucher.title)' found and applied!")
////            } else {
////                 print("Preview: Hidden voucher code '\(code)' not valid.")
////            }
////        }
////    )
//    let voucherServiceInstance = VoucherService(apiClient: ApiClient(baseURLString: base_url))
//    
//    VoucherView(voucherVM: VoucherViewModel(voucherService: voucherServiceInstance))
//}
