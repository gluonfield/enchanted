//
//  UseDocumentView.swift
//  Enchanted
//
//  Created by Daniel on 3/22/25.
//

import SwiftUI

struct UseDocumentView: View {
    @Binding var documentUsage: Bool

    @State var retrievalStore = RetrievalStore.shared
    @State var presentPopover: Bool = false
    @State var showRetrieval: Bool = false

    private func selectDatabase(database: DatabaseSD, overWrite: Bool) {
        retrievalStore.selectDatabase(database: database, overWrite: overWrite)
    }

    private func showRetrievalTap() {
        showRetrieval.toggle()
    }

    var body: some View {
        Button(action: {
            presentPopover.toggle()
        }, label: {
            Image(systemName: "doc.text.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(documentUsage ? Color.blue : Color.gray)
                .font(.system(size: 20))
        })
        .tint(documentUsage ? Color.blue : Color.gray)
        .buttonStyle(PlainButtonStyle())
        .clipShape(Capsule())
        .popover(isPresented: $presentPopover, content: {
            VStack {
                if (retrievalStore.databases.count == 0) {
                    VStack {
                        Image(systemName: "tray.and.arrow.down")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding(.bottom, 6)

                        Text("Add Document")
                            .foregroundStyle(Color.blue)
                            .onTapGesture {
                                showRetrievalTap()
                            }

                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    Text("Documents")
                        .padding()
                        .font(.system(size:20))

                    ScrollView {
                        VStack {
                            ForEach(retrievalStore.databases, id:\.self) { _database in
                                UseDocumentViewItem(database: _database, selectedDatabase: retrievalStore.selectedDatabase, selectDatabase: selectDatabase)
                            }
                        }
                    }
#if os(macOS) || os(visionOS)
                    .frame(maxHeight: 350)
#elseif os(iOS)
                    .frame(maxHeight: .infinity)
#endif
                }

                Divider()

                HStack {
                    VStack(alignment: .leading) {
                        Text("Enable using document")
                        Text("Enchanted can use the document")
                            .foregroundStyle(Color.gray)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .layoutPriority(1)

                    Spacer()

                    Toggle("", isOn: $documentUsage)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .disabled(retrievalStore.databases.count == 0)
                }
                .padding()
            }
        })
        .sheet(isPresented: $showRetrieval) {
            Retrieval()
        }
    }
}



#Preview {
    @Previewable @State var documentUsage: Bool = false

    UseDocumentView(documentUsage: $documentUsage)
}
