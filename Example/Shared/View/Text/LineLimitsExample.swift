//
//  LineLimitsExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct LineLimitExample: View {
    var body: some View {
        Text(
            "This is a long string that demonstrates the effect of OpenSwiftUI's lineLimit(:_) operator."
        )
        .frame(width: 200, height: 200, alignment: .leading)
        .lineLimit(2)
    }
}

struct LineLimitReservesSpaceExample: View {
    var body: some View {
        VStack {
            Text("Title")
                .font(.headline)
                .lineLimit(2, reservesSpace: true)
            Text("Subtitle")
                .font(.subheadline)
                .lineLimit(4, reservesSpace: true)
        }
    }
}
