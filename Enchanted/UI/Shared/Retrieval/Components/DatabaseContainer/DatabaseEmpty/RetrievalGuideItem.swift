//
//  RetrievalGuideItem.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct RetrievalGuideItem: View {
    var guide: RetrievalGuide

    var body: some View {
        HStack {
            Image(systemName: guide.imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 40)
                .foregroundColor(guide.imageColor)
#if os(macOS)
                .padding()
#endif

            Text("\(guide.description)")
                .lineLimit(15)
                .font(.system(size: 16))
#if os(macOS)
                .lineSpacing(5)
#endif
                .fixedSize(horizontal: false, vertical: true)
                .padding(10)
        }
        .frame(maxHeight: 100)
    }
}

#Preview {
    var guide: RetrievalGuide = RetrievalGuide(imageSystemName: "plus.rectangle.on.folder", imageColor: Color(hex: "428564"), order: 1, description: "Create a database of documents for your task. It may be course notes, legal documents, coding project or anything else. Files always stay local to your machine.")

    RetrievalGuideItem(guide: guide)
}
