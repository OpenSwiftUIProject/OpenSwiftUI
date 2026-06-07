//
//  DisplayListStdoutRendererTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenCoreGraphicsShims
import OpenSwiftUICore
import Testing

struct DisplayListStdoutRendererTests {
    @Test
    func emptyListDescription() {
        let list = DisplayList()

        #expect(list.stdoutDescription(
            surface: CGSize(width: 64.0, height: 32.0),
            version: .init(decodedValue: 7)
        ) == """
        OpenSwiftUI backend: stdout
        surface: 64.0x32.0
        display-list-version: 7
        rendered:
        """)
    }

    @Test
    func colorContentDescription() {
        let item = item(
            .content(.init(
                .color(.init(colorSpace: .sRGBLinear, red: 1.0, green: 0.0, blue: 0.0)),
                seed: .init(decodedValue: 2)
            )),
            frame: CGRect(x: 1.0, y: 2.0, width: 30.0, height: 40.0)
        )

        #expect(DisplayList(item).stdoutDescription(
            surface: CGSize(width: 100.0, height: 80.0),
            version: .init(decodedValue: 4)
        ) == """
        OpenSwiftUI backend: stdout
        surface: 100.0x80.0
        display-list-version: 4
        rendered:
          - fill x:1.0 y:2.0 w:30.0 h:40.0 #FF0000FF
        """)
    }

    @Test
    func shapeContentDescription() {
        let color = Color.Resolved(colorSpace: .sRGBLinear, red: 0.0, green: 1.0, blue: 0.0)
        let item = item(
            .content(.init(
                .shape(Path(CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)), _AnyResolvedPaint(color), FillStyle()),
                seed: .init(decodedValue: 3)
            )),
            frame: CGRect(x: 5.0, y: 6.0, width: 70.0, height: 80.0)
        )

        #expect(DisplayList(item).stdoutDescription(
            surface: CGSize(width: 120.0, height: 90.0),
            version: .init(decodedValue: 5)
        ) == """
        OpenSwiftUI backend: stdout
        surface: 120.0x90.0
        display-list-version: 5
        rendered:
          - fill x:5.0 y:6.0 w:70.0 h:80.0 #00FF00FF
        """)
    }

    @Test
    func opacityAndTransformDescription() {
        let child = item(
            .content(.init(
                .color(.init(colorSpace: .sRGBLinear, red: 0.0, green: 0.0, blue: 1.0)),
                seed: .init(decodedValue: 2)
            )),
            frame: CGRect(x: 1.0, y: 2.0, width: 3.0, height: 4.0)
        )
        let transformed = item(
            .effect(
                .transform(.affine(CGAffineTransform(translationX: 10.0, y: 20.0))),
                DisplayList(child)
            ),
            frame: .zero
        )
        let faded = item(
            .effect(.opacity(0.5), DisplayList(transformed)),
            frame: .zero
        )

        #expect(DisplayList(faded).stdoutDescription(
            surface: CGSize(width: 100.0, height: 100.0),
            version: .init(decodedValue: 6)
        ) == """
        OpenSwiftUI backend: stdout
        surface: 100.0x100.0
        display-list-version: 6
        rendered:
          - fill x:11.0 y:22.0 w:3.0 h:4.0 #0000FF80
        """)
    }

    @Test
    func statesDescription() {
        let redItem = item(
            .content(.init(
                .color(.init(colorSpace: .sRGBLinear, red: 1.0, green: 0.0, blue: 0.0)),
                seed: .init(decodedValue: 1)
            )),
            frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 20.0)
        )
        let blueItem = item(
            .content(.init(
                .color(.init(colorSpace: .sRGBLinear, red: 0.0, green: 0.0, blue: 1.0)),
                seed: .init(decodedValue: 2)
            )),
            frame: CGRect(x: 30.0, y: 40.0, width: 50.0, height: 60.0)
        )
        let states = item(
            .states([
                (StrongHash(of: 1), DisplayList(redItem)),
                (StrongHash(of: 2), DisplayList(blueItem)),
            ]),
            frame: .zero
        )

        #expect(DisplayList(states).stdoutDescription(
            surface: CGSize(width: 200.0, height: 150.0),
            version: .init(decodedValue: 8)
        ) == """
        OpenSwiftUI backend: stdout
        surface: 200.0x150.0
        display-list-version: 8
        rendered:
          - fill x:0.0 y:0.0 w:10.0 h:20.0 #FF0000FF
          - fill x:30.0 y:40.0 w:50.0 h:60.0 #0000FFFF
        """)
    }

    private func item(
        _ value: DisplayList.Item.Value,
        frame: CGRect,
        identity: DisplayList.Identity = .init(decodedValue: 1),
        version: DisplayList.Version = .init(decodedValue: 0)
    ) -> DisplayList.Item {
        DisplayList.Item(
            value,
            frame: frame,
            identity: identity,
            version: version
        )
    }
}
