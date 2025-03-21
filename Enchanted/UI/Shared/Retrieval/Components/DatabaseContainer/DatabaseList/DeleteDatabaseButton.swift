//
//  DeleteDatabaseButton.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct DeleteDatabaseButton: View {
    var handleDeleteDatabase: () -> ()

    @State private var isPresented: Bool = false

    private func onDeleteTap() {
        isPresented.toggle()
        handleDeleteDatabase()
    }

    var body: some View {
        Button("Delete") {
            isPresented.toggle()
        }
        .tint(.red)
        .buttonStyle(BorderedProminentButtonStyle())
        .alert("Are you sure you want to delete this database?", isPresented: $isPresented, actions: {
            Button("Delete", role: .destructive) {
                onDeleteTap()
            }

            Button("Cancel", role: .cancel) {
                isPresented.toggle()
            }
        })
    }
}

#Preview {
    DeleteDatabaseButton(handleDeleteDatabase: {})
}
