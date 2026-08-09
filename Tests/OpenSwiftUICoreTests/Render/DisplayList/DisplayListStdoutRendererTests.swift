//
//  DisplayListStdoutRendererTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenCoreGraphicsShims
@_spi(WebRenderer) import OpenSwiftUICore
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
        let selectedState = item(
            .effect(.state(StrongHash(of: 2)), DisplayList(states)),
            frame: .zero
        )

        #expect(DisplayList(selectedState).stdoutDescription(
            surface: CGSize(width: 200.0, height: 150.0),
            version: .init(decodedValue: 8)
        ) == """
        OpenSwiftUI backend: stdout
        surface: 200.0x150.0
        display-list-version: 8
        rendered:
          - fill x:30.0 y:40.0 w:50.0 h:60.0 #0000FFFF
        """)
    }

    @Test
    func unmatchedStateIsEmpty() {
        let content = item(
            .content(.init(
                .color(.init(colorSpace: .sRGBLinear, red: 1.0, green: 0.0, blue: 0.0)),
                seed: .init(decodedValue: 1)
            )),
            frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 20.0)
        )
        let states = item(
            .states([(StrongHash(of: 1), DisplayList(content))]),
            frame: .zero
        )
        let unmatchedState = item(
            .effect(.state(StrongHash(of: 2)), DisplayList(states)),
            frame: .zero
        )

        #expect(DisplayList(unmatchedState).stdoutDescription(
            surface: CGSize(width: 100.0, height: 100.0),
            version: .init(decodedValue: 9)
        ) == """
        OpenSwiftUI backend: stdout
        surface: 100.0x100.0
        display-list-version: 9
        rendered:
        """)
    }

    @Test
    func webFrame() {
        let item = item(
            .content(.init(
                .color(.init(colorSpace: .sRGBLinear, red: 1.0, green: 0.5, blue: 0.0)),
                seed: .init(decodedValue: 2)
            )),
            frame: CGRect(x: 8.0, y: 12.0, width: 32.0, height: 48.0)
        )

        let frame = DisplayList(item).webRenderFrame(
            surface: CGSize(width: 320.0, height: 240.0),
            version: .init(decodedValue: 9)
        )

        #expect(frame.surface == CGSize(width: 320.0, height: 240.0))
        #expect(frame.version == 9)
        #expect(frame.commands.count == 1)
        guard case let .fill(rect, transform, cssColor) = frame.commands[0] else {
            Issue.record("Expected a fill command")
            return
        }
        #expect(rect == CGRect(x: 0.0, y: 0.0, width: 32.0, height: 48.0))
        #expect(transform == CGAffineTransform(translationX: 8.0, y: 12.0))
        #expect(cssColor == "#FFBC00FF")
    }

    @Test
    func webFramePreservesAffineTransformAndClampsCSSColor() {
        let content = item(
            .content(.init(
                .color(.init(
                    colorSpace: .sRGBLinear,
                    red: 4.0,
                    green: -1.0,
                    blue: .nan,
                    opacity: 2.0
                )),
                seed: .init(decodedValue: 3)
            )),
            frame: CGRect(x: 2.0, y: 3.0, width: 4.0, height: 5.0)
        )
        let rotation = CGAffineTransform(
            a: 0.0,
            b: 1.0,
            c: -1.0,
            d: 0.0,
            tx: 0.0,
            ty: 0.0
        )
        let transformed = item(
            .effect(.transform(.affine(rotation)), DisplayList(content)),
            frame: .zero
        )

        let frame = DisplayList(transformed).webRenderFrame(
            surface: CGSize(width: 20.0, height: 20.0),
            version: .init(decodedValue: 10)
        )

        #expect(frame.commands.count == 1)
        guard case let .fill(rect, transform, cssColor) = frame.commands[0] else {
            Issue.record("Expected a fill command")
            return
        }
        #expect(rect == CGRect(x: 0.0, y: 0.0, width: 4.0, height: 5.0))
        #expect(transform == rotation.translatedBy(x: 2.0, y: 3.0))
        #expect(cssColor == "#FF0000FF")
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
