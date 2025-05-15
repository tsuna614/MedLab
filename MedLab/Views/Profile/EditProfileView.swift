//
//  EditProfileView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 14/5/25.
//
import SwiftUI

struct EditProfileView: View {
    @StateObject var viewModel: EditProfileViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var snackbarViewModel: SnackBarViewModel
    @Environment(\.dismiss) var dismiss
    
//    @EnvironmentObject var appViewModel: AppViewModel
//
//    init(user: User?) {
//        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user, appViewModel: appViewModel))
//    }

    var body: some View {
        Form {
            // --- Personal Information Section ---
            Section(header: Text("Personal Information").font(.headline).padding(.top)) { // Added padding to header
                FormFieldView(
                    iconName: "person.fill",
                    title: "First Name",
                    text: $viewModel.firstName,
                    prompt: "Enter first name",
                    textContentType: .givenName
                )
                FormFieldView(
                    iconName: "person.fill",
                    title: "Last Name",
                    text: $viewModel.lastName,
                    prompt: "Enter last name",
                    textContentType: .familyName
                )
                FormFieldView(
                    iconName: "phone.fill",
                    title: "Phone Number",
                    text: $viewModel.phoneNumber,
                    prompt: "Optional",
                    keyboardType: .phonePad,
                    textContentType: .telephoneNumber
                )
                FormFieldView(
                    iconName: "envelope.fill",
                    title: "Email",
                    text: $viewModel.email,
                    prompt: "Optional",
                    textContentType: .emailAddress,
                    isEditable: false
                )

//                // Display non-editable email
//                if let email = viewModel.originalUser?.email {
//                    HStack {
//                        Image(systemName: "envelope.fill")
//                            .foregroundColor(.gray)
//                            .frame(width: 20, alignment: .center)
//                        Text("Email:")
//                        Spacer()
//                        Text(email)
//                            .foregroundColor(.secondary)
//                    }
//                    .padding(10)
//                }
            }
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10)) // Adjust spacing for rows

            // --- Address Section ---
            Section(header: Text("Address").font(.headline)) {
                FormFieldView(
                    iconName: "numbers.rectangle.fill", // Or "location.fill"
                    title: "Address",
                    text: $viewModel.address,
                    prompt: "Enter address number",
                    textContentType: .streetAddressLine1
                )
                FormFieldView(
                    iconName: "house.fill", // Or "location.fill"
                    title: "Street",
                    text: $viewModel.street,
                    prompt: "Enter street",
                    textContentType: .streetAddressLine1
                )
                FormFieldView(
                    iconName: "building.2.fill", // Or "map.fill"
                    title: "City",
                    text: $viewModel.city,
                    prompt: "Enter city",
                    textContentType: .addressCity
                )
                FormFieldView(
                    iconName: "mappin.and.ellipse",
                    title: "State / Province",
                    text: $viewModel.state,
                    prompt: "Enter state or province",
                    textContentType: .addressState
                )
                FormFieldView(
                    iconName: "number.square.fill", // Or "signpost.right.fill"
                    title: "Postal Code",
                    text: $viewModel.postalCode,
                    prompt: "Enter postal code",
                    textContentType: .postalCode
                )
                FormFieldView(
                    iconName: "globe.americas.fill",
                    title: "Country",
                    text: $viewModel.country,
                    prompt: "Enter country",
                    textContentType: .countryName
                )
            }
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))

            // --- Save Button Section ---
            Section {
                Button(action: {
                    Task {
                        await viewModel.saveProfileChanges()
                        if viewModel.saveSuccess {
//                            // Update AppViewModel
//                            if let originalUser = viewModel.originalUser {
//                                let updatedUser = User( /* ... construct updated User ... */
//                                    id: originalUser.id, email: originalUser.email, firstName: viewModel.firstName,
//                                    lastName: viewModel.lastName, number: viewModel.phoneNumber.isEmpty ? nil : viewModel.phoneNumber,
//                                    userType: originalUser.userType, receiptsId: originalUser.receiptsId,
//                                    address: Address(address: viewModel.address, street: viewModel.street, city: viewModel.city, state: viewModel.state,
//                                                     postalCode: viewModel.postalCode, country: viewModel.country)
//                                )
//                                appViewModel.user = updatedUser
//                            }
                            snackbarViewModel.showSnackbar(message: "User updated successfully")
                            dismiss()
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            snackbarViewModel.showSnackbar(message: errorMessage)
                        }
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Save Changes")
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isSaving)
            }

//            // Display error message if any
//            if let errorMessage = viewModel.errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .frame(maxWidth: .infinity, alignment: .center)
////                Section {
////                }
//            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// EditProfileViewModel definition (keep as is)
// @MainActor class EditProfileViewModel: ObservableObject { ... }

// User and Address models (keep as is)
// struct User: Codable { ... }
// struct Address: Codable { ... }
