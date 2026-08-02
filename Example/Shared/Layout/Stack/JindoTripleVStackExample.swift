//
//  JindoTripleVStackExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Jindo) import OpenSwiftUI
#else
import SwiftUI_SPI
#endif

struct JindoTripleVStackExample: View {
    var body: some View {
        #if os(macOS)
        Text("JindoTripleVStack is unavailable on macOS")
        #else
        JindoTripleVStack(
            configuration: .init(
                notchSize: CGSize(width: 120, height: 36),
                horizontalSizing: .split,
                layoutMargins: EdgeInsets(
                    top: 8,
                    leading: 16,
                    bottom: 16,
                    trailing: 16
                )
            )
        ) {
            region("Leading", color: .blue)
                .jindoPosition(.leading)

            region("Center", color: .purple)
                .jindoPosition(.center)

            region("Trailing", color: .orange)
                .jindoPosition(.trailing)

            Capsule()
                .fill(.black)
                .jindoPosition(.notch)

            Text("Bottom content shared by all three stacks")
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.green)
                .jindoPosition(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.15))
        .padding()
        #endif
    }

    #if !os(macOS)
    private func region(_ title: String, color: Color) -> some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(color)
    }
    #endif
}
