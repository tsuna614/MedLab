//
//  EditProfileViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 14/5/25.
//

import SwiftUI
import Combine

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    
    @Published var address: String = ""
    @Published var street: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var postalCode: String = ""
    @Published var country: String = ""

    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    @Published var saveSuccess: Bool = false

    var originalUser: User?
    
    private let appViewModel: AppViewModel

    init(user: User?, appViewModel: AppViewModel) {
        self.originalUser = user
        self.appViewModel = appViewModel
        populateFields(from: user)
    }

    func populateFields(from user: User?) {
        guard let user = user else { return }
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.phoneNumber = user.number ?? ""
        self.address = user.address?.address ?? ""
        self.street = user.address?.street ?? ""
        self.city = user.address?.city ?? ""
        self.state = user.address?.state ?? ""
        self.postalCode = user.address?.postalCode ?? ""
        self.country = user.address?.country ?? ""
        self.email = user.email
    }

    func saveProfileChanges() async {
        guard !isSaving else { return }

        print("EditProfileViewModel: Attempting to save profile changes...")
        isSaving = true
        errorMessage = nil
        saveSuccess = false

        // if they are not all empty,
        if !address.isEmpty || !street.isEmpty || !city.isEmpty || !country.isEmpty {
            guard !address.isEmpty, !street.isEmpty, !city.isEmpty, !country.isEmpty else {
                errorMessage = "Please enter all required fields for address."
                isSaving = false
                return
            }
        }
        
        let updatedAddress = Address(
            address: address,
            street: street,
            city: city,
            state: state,
            postalCode: postalCode,
            country: country
        )
        
        let newUser = User(
            id: "",
            email: email,
            firstName: firstName,
            lastName: lastName,
            number: phoneNumber,
            userType: nil,
            receiptsId: nil,
            address: address.isEmpty ? nil : updatedAddress
        )
        
        appViewModel.updateUser(newUser: newUser)
        saveSuccess = true
        isSaving = false

//        do {
//            try await Task.sleep(nanoseconds: 1_500_000_000)
//            
//            print("EditProfileViewModel: Profile changes saved successfully (simulated).")
//            saveSuccess = true
//
//        } catch {
//            print("❌ EditProfileViewModel: Failed to save profile - \(error)")
//            errorMessage = "Could not save profile changes. Please try again."
//        }


    }
}
