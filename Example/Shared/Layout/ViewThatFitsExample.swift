//
//  ViewThatFitsExample.swift
//  Shared

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct UploadProgressView: View {
    var uploadProgress: Double

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Text("\(uploadProgress.formatted(.percent))")
                ProgressView(value: uploadProgress)
                    .frame(width: 100)
            }
            ProgressView(value: uploadProgress)
                .frame(width: 100)
            Text("\(uploadProgress.formatted(.percent))")
        }
    }
}

struct ViewThatFitsExample: View {
    var body: some View {
        VStack {
            UploadProgressView(uploadProgress: 0.75)
                .frame(maxWidth: 200)
            UploadProgressView(uploadProgress: 0.75)
                .frame(maxWidth: 100)
            UploadProgressView(uploadProgress: 0.75)
                .frame(maxWidth: 50)
        }
    }
}

#Preview {
    ViewThatFitsExample()
}
