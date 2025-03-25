//
//  ImportFilesButton.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct ImportFilesButton: View {
    var handleAttachFiles: ([URL]) -> ()

    @State private var presentModal: Bool = false

    var body: some View {
        Button(action: {presentModal.toggle()}) {
            Text("Import files")
        }
        .fileImporter(
            isPresented: $presentModal,
            allowedContentTypes: [.data],
            allowsMultipleSelection: true,
            onCompletion: { result in
                switch result {
                    case .success(let urls):
                        handleAttachFiles(urls)

                    case .failure(let error):
                        print("File import error: \(error.localizedDescription)")
                }
            }
        )
    }
}
