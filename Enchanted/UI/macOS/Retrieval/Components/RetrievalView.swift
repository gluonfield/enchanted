//
//  RetrievalView.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import SwiftUI

struct RetrievalView: View {
    @Environment(\.presentationMode) var presentationMode
    var databases: [DatabaseSD]
    @Binding var selectedDatabase: DatabaseSD?
    var languageModels: [LanguageModelSD]
    var documents: [DocumentSD]
    var onCreateDatabase: (String, String) -> ()
    var onAddDocuments: (UUID, [URL]) -> ()
    var onIndexDocuments: (UUID) -> ()
    var documentsProgress: Double
    
    @State private var showGuide = false
    @State private var selectingFiles = false
    @State private var selectedLanguageModel: LanguageModelSD?
    
    private func onIndexDocumentsTap() {
        guard let selectedDatabase = selectedDatabase, let _ = selectedLanguageModel else { return }
        onIndexDocuments(selectedDatabase.id)
    }
    
    private func onCreateDatabaseTap() {
        guard let selectedLanguageModel = selectedLanguageModel else { return }
        onCreateDatabase("Hot dog", selectedLanguageModel.name)
    }
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: onCreateDatabaseTap) {
                        Text("New Database")
                    }
                    
                    Spacer()
                    
                    Button(action: {presentationMode.wrappedValue.dismiss()}) {
                        Text("Close")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(.label))
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
            .padding(.bottom)
            
            VStack {
                EmptyDatabaseView()
                    .padding(.bottom, 30)
                    .padding(.horizontal, 20)
                    .showIf(databases.isEmpty)
                
                HStack {
                    Picker(selection: $selectedDatabase) {
                        ForEach(databases, id:\.self) { database in
                            Text(database.name).tag(Optional(database))
                        }
                    } label: {
                        Text("Database")
                            .font(.system(size: 14))
                            .fontWeight(.regular)
                    }
                    .frame(maxWidth: 300)
                    
                    Text("using " +  (selectedDatabase?.model?.name ?? "Unknown"))
                    
                    Spacer()
                    
                }
                .showIf(!databases.isEmpty)
                
                DatabaseView(documents: documents)
                    .padding(.top, 20)
                    .showIf(!databases.isEmpty)
            }
            .padding([.horizontal, .bottom])
            
            HStack {
                Spacer()
                Button(action: {selectingFiles.toggle()}) {
                    Text("Import files")
                }
                .fileImporter(isPresented: $selectingFiles,
                              allowedContentTypes: [.directory],
                              onCompletion: { result in
                    switch result {
                    case .success(let url):
                        guard url.startAccessingSecurityScopedResource() else { return }
                        
                        var files = [URL]()
                        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                            for case let fileURL as URL in enumerator {
                                do {
                                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                                    if fileAttributes.isRegularFile! {
                                        files.append(fileURL)
                                    }
                                } catch { print(error, fileURL) }
                            }
                            print(files)
                            guard let selectedDatabase = selectedDatabase else { return }
                            onAddDocuments(selectedDatabase.id, files)
                        }
//                        url.stopAccessingSecurityScopedResource()
                    case .failure(let error):
                        print(error)
                    }
                })
                
                Button(action: onIndexDocumentsTap) {
                    Text("Start Indexing")
                }
                .buttonStyle(.borderedProminent)
                
            }
            .padding()
            
            HStack {
                ProgressView(value: documentsProgress)
            }
//            .showIf(documentsProgress)
            .padding()
        }
        .frame(minWidth: 700, maxWidth: 800, minHeight: 500)
        .onAppear {
            selectedLanguageModel = languageModels.first
        }
        .onChange(of: documentsProgress) { oldValue, newValue in
            print(oldValue, newValue, "changed")
        }
    }
}

#Preview {
    RetrievalView(
        databases: DatabaseSD.sample,
        selectedDatabase: .constant(DatabaseSD.sample.first),
        languageModels: LanguageModelSD.sample,
        documents: DocumentSD.sample,
        onCreateDatabase: {_,_ in},
        onAddDocuments: {_,_ in},
        onIndexDocuments: {_ in},
        documentsProgress: 0.5
    )
    .frame(width: 700)
}
