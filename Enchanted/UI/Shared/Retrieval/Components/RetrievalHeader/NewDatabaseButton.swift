//
//  NewDatabaseButton.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct NewDatabaseButton: View {
    var createDatabase: (String) -> ()

    @State private var isPresented: Bool = false
    @State private var databaseName: String = ""

    private func onCreateTap() {
        isPresented.toggle()
        createDatabase(databaseName)
        databaseName = ""
    }

    var body: some View {
        Button("New Database") {
            isPresented.toggle()
        }
        .alert("Enter database name", isPresented: $isPresented, actions: {
            Button("Create") {
                onCreateTap()
            }
            .disabled(databaseName.trimmingCharacters(in: .whitespaces).isEmpty)

            Button("Cancel", role: .cancel) {
                isPresented.toggle()
            }

            TextField(text: $databaseName, label: {

            })
            .padding()
        })
    }
}

#Preview {
    NewDatabaseButton(createDatabase: {_ in})
}
