//
//  UseDocumentViewItem.swift
//  Enchanted
//
//  Created by Daniel on 3/22/25.
//

import SwiftUI

struct UseDocumentViewItem: View {
    var database: DatabaseSD
    var selectedDatabase: DatabaseSD?
    var selectDatabase: (DatabaseSD, Bool) -> ()

    @State var isHovered: Bool = false

    var body: some View {
        Button(action: {
            if (selectedDatabase != database) {
                selectDatabase(database, true)
            }
        }, label: {
            HStack {
                VStack (alignment: .leading) {
                    Text("\(String(describing: database.name))")
                        .font(.system(size: 18))
                    if let modelName = database.model?.name {
                        Text("\(String(describing: modelName))")
                            .foregroundStyle(Color.gray)
                    }
                }

                Spacer()

                if (selectedDatabase?.id == database.id) {
                    Image(systemName: "checkmark")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
#if os(macOS)
            .frame(width: 300)
#endif
            .onHover{_ in
                isHovered.toggle()
            }
            .background(Color.white.opacity(isHovered ? 0.2 : 0))
        })
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    UseDocumentViewItem(database: DatabaseSD.sample[0], selectDatabase: {_,_ in})
}
