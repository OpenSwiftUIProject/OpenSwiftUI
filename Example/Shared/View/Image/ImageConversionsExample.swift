//
//  ImageConversionsExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct ImageConversionsExample: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                Image(platformImage: PlatformImage(named: "logo")!)
                    .resizable()
                    .frame(width: 100, height: 100)
            }.environment(\.colorScheme, .light)
            VStack(spacing: 0) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                Image(platformImage: PlatformImage(named: "logo")!)
                    .resizable()
                    .frame(width: 100, height: 100)
            }.environment(\.colorScheme, .dark)
        }
    }
}

struct ImageConversionsSystemImageExample: View {
    private var image: PlatformImage {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        NSImage(named: NSImage.addTemplateName)!
        #elseif canImport(UIKit)
        UIImage(systemName: "star.fill")!
        #endif
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Image(platformImage: image)
                    .resizable()
                    .frame(width: 100, height: 100)
                #if canImport(AppKit) && !targetEnvironment(macCatalyst)
                Image(platformImage: image)
                    .resizable()
                    .frame(width: 100, height: 100)
                #else
                Image(platformImage: image.withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .frame(width: 100, height: 100)
                #endif
            }.environment(\.colorScheme, .light)
            VStack(spacing: 0) {
                Image(platformImage: image)
                    .resizable()
                    .frame(width: 100, height: 100)
                Image(platformImage: image)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 100, height: 100)
            }.environment(\.colorScheme, .dark)
        }.foregroundStyle(.red)
    }
}
