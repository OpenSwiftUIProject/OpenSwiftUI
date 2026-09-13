@testable import OpenSwiftUI
import Testing

struct LabelTests {
    @Test
    func hasTheExpectedChildren() {
        final icon = Image("add")
        final text = Text("test")
        final label = Label("test", "add")
        // TODO Actualy validate contents
        expect(label.title == text, true)
        expect(label.icon == icon, true)
    }
}
