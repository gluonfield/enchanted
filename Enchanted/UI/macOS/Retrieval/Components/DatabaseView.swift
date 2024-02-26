//
//  DatabaseView.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import SwiftUI

struct DatabaseView: View {
    var documents: [DocumentSD]
    
    var body: some View {
        Table(documents) {
            TableColumn("Path") { document in
                Text(document.documentUrl?.absoluteString ?? "")
                    .truncationMode(.head)
            }
            TableColumn("Status") { document in
                document.status.icon
            }
        }
    }
}

#Preview {
    DatabaseView(documents: DocumentSD.sample)
}
