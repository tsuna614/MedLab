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

    init(user: User?) {
        self.originalUser = user
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

        
//        let updatedAddress = Address(
//            street: street,
//            city: city,
//            state: state,
//            postalCode: postalCode,
//            country: country
//        )
//
//        guard let currentUserId = originalUser?.id else {
//            errorMessage = "User ID missing. Cannot save."
//            isSaving = false
//            return
//        }

//        let updatedUserData = User( // This is for local update, API might take partial
//            id: currentUserId,
//            email: originalUser?.email ?? "", // Email typically not editable
//            firstName: firstName,
//            lastName: lastName,
//            number: phoneNumber.isEmpty ? nil : phoneNumber,
//            userType: originalUser?.userType, // Usually not editable by user
//            receiptsId: originalUser?.receiptsId,
//            address: updatedAddress
//        )

        do {
            // In a real app:
            // try await userService.updateUserProfile(userId: currentUserId, data: updateUserRequest)
            try await Task.sleep(nanoseconds: 1_500_000_000) // Simulate network delay

            print("EditProfileViewModel: Profile changes saved successfully (simulated).")
            saveSuccess = true
            // Important: After successful API save, you need to update the
            // user object in your AppViewModel so the rest of the app sees the changes.
            // This could be done via a callback, a shared service, or directly if
            // EditProfileViewModel has a reference to AppViewModel.

        } catch {
            print("❌ EditProfileViewModel: Failed to save profile - \(error)")
            errorMessage = "Could not save profile changes. Please try again."
        }

        isSaving = false
    }
}
