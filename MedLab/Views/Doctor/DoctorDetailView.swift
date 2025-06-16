//
//  DoctorDetailView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 14/6/25.
//

import SwiftUI

struct DoctorDetailView: View {
    let doctor: Doctor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header Section (Image, Name, Specialty)
                headerSection

                // MARK: - About Section
                if let bio = doctor.shortBio, !bio.isEmpty {
                    sectionTitle("About Dr. \(doctor.lastName)")
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                // MARK: - Credentials Section
                sectionTitle("Credentials")
                VStack(alignment: .leading, spacing: 10) {
                    credentialRow(icon: "graduationcap.fill", title: "Specialty", value: doctor.medicalSpecialty)
                    if let qualifications = doctor.qualifications, !qualifications.isEmpty {
                        credentialRow(icon: "rosette", title: "Qualifications", value: qualifications)
                    }
                    credentialRow(icon: "figure.stand", title: "Experience", value: "\(doctor.yearsOfExperience) years (Since \(String(doctor.startingYear)))")

                }
                .padding(.horizontal)

                // MARK: - Consultation Info (Optional)
                if doctor.consultationFeeRange != nil {
                    sectionTitle("Consultation & Clinic")
                    VStack(alignment: .leading, spacing: 10) {
                        if let fee = doctor.consultationFeeRange, !fee.isEmpty {
                            credentialRow(icon: "dollarsign.circle.fill", title: "Fee Range", value: fee)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                 Button {
                     print("Book appointment with \(doctor.fullName)")
                 } label: {
                     Text("Book Appointment")
                         .font(.headline)
                         .foregroundColor(.white)
                         .frame(maxWidth: .infinity)
                         .padding()
                         .background(Color.blue)
                         .cornerRadius(10)
                 }
                 .padding()

            }
            .padding(.vertical)
        }
        .navigationTitle(doctor.fullName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews for Cleaner Body

    private var headerSection: some View {
        VStack(spacing: 15) {
            AsyncImage(url: URL(string: doctor.profileImageUrl ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                        .shadow(radius: 5)
                } else if phase.error != nil {
                    Image(systemName: "person.crop.circle.fill.badge.exclamationmark")
                        .font(.system(size: 120))
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .frame(height: 150)

            Text(doctor.fullName)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)

            Text(doctor.medicalSpecialty)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title2.weight(.semibold))
            .padding(.horizontal)
            .padding(.top, 10)
    }

    private func credentialRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 25, alignment: .center)
                .padding(.top, 2)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}
