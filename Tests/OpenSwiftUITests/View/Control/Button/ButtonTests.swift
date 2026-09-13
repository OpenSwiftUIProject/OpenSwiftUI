//
//  ButtonTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ButtonTests {
    @Test
    func enabledButtonInvokesAction() {
        var clicked = false;
        var cb = {
            clicked = true;
        }

        var button = Button ("Run", cb)
        // TODO: Trigger attempt to press button.
        expect(clicked, true);
    }
    @Test
    func disabledButtonDoesntInvokeAction() {
        var clicked = false;
        var cb = {
            clicked = true;
        };

        var button = Button ("Run", cb)

        // TODO: Attempt to trigger the button.
        expect(clicked, false);
    }
}
