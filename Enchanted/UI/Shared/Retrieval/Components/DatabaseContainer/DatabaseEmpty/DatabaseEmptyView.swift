//
//  DatabaseEmptyView.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct DatabaseEmptyView: View {
    private var guides: [RetrievalGuide] = [
        RetrievalGuide(imageSystemName: "plus.rectangle.on.folder", imageColor: Color(hex: "428564"), order: 1, description: "Create a database of documents for your task. It may be course notes, legal documents, coding project or anything else. Files always stay local to your machine."),
        RetrievalGuide(imageSystemName: "doc.on.doc", imageColor: Color(hex: "9b72cb"), order: 2, description: "Import documents. Enchanted will create text embeddings based on the selected model. Currently text and PDF files are supported."),
        RetrievalGuide(imageSystemName: "message.badge", imageColor: Color(hex: "d96570"), order: 3, description: "Make prompts using your database. Enchanted will include snippets of relevant your documents when sending the prompt."),
    ]

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("How it works")
                .font(Font.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "4285f4"), Color(hex: "9b72cb"), Color(hex: "d96570"), Color(hex: "#d96570")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            VStack (alignment: .leading, spacing: 20) {
                ForEach(guides) { guide in
                    RetrievalGuideItem(guide: guide)
                }
            }
        }
        .padding(20)
    }
}

#Preview {
    DatabaseEmptyView()
}
