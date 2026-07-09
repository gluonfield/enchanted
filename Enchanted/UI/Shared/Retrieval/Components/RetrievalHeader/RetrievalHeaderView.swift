//
//  RetrievalHeaderView.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct RetrievalHeaderView: View {
    @Environment(\.presentationMode) var presentationMode

    var createDatabase: (String) -> ()

    var body: some View {
        ZStack {
            HStack {
                NewDatabaseButton { newDatabaseName in
                    createDatabase(newDatabaseName)
                }

                Spacer()

                Button(action: {presentationMode.wrappedValue.dismiss()}) {
                    Text("Close")
                }
            }

            HStack {
                Spacer()
                Text("Retrieval")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.label))
                Spacer()
            }
        }
        .padding()
    }
}
