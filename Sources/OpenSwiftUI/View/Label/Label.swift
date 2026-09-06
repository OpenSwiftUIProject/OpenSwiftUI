import Foundation 

nonisolated struct Label<Title,Icon>: View where Title: View, Icon: View {
    private init(title: Title, icon: Icon) {
        self.title = title;
        self.icon = icon
    }
    init(@ViewBuilder title: () -> Title, @ViewBuilder icon: () -> Icon) {
        self.title = title();
        self.icon = icon();
    }

    var title: Title;
    var icon: Icon;

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            title
            icon
        }
    }
}

extension Label where Title == Text, Icon == Image {
    nonisolated
    init(_ title: LocalizedStringResource, image name: String) {
        self.init(title: Text(title), icon: Image(name))
    }

    nonisolated
    init(_ title: LocalizedStringResource, image resource: ImageResource) {
        self.init(title: Text(title), icon: Image(resource))
    }
     nonisolated
    init(_ title: LocalizedStringKey, image name: String) {
        self.init(title: Text(title), icon: Image(name))
    }

    nonisolated
    init(_ title: LocalizedStringKey, image resource: ImageResource) {
        self.init(title: Text(title), icon: Image(resource))
    }
     nonisolated
    init<S>(_ title: S, image name: String) where S: StringProtocol {
        self.init(title: Text(title), icon: Image(name))
    }

    nonisolated
    init<S>(_ titleResource: S, image resource: ImageResource) where S: StringProtocol {
        self.init(title: Text(titleResource), icon: Image(resource))
    }
}