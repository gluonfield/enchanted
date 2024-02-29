//
//  CircularProgressIndicator.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 27/02/2024.
//

import SwiftUI
import ActivityIndicatorView

struct CircularProgressView: View {
  let progress: CGFloat

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 2)
        .opacity(0.2)
        .foregroundColor(.blue)

      Circle()
        .trim(from: 0.0, to: min(progress, 1.0))
        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .foregroundColor(.blue)
        .rotationEffect(Angle(degrees: 270.0))
        .animation(.linear, value: progress)
    }
  }
}

#Preview {
    CircularProgressView(progress: 0.3)
}
