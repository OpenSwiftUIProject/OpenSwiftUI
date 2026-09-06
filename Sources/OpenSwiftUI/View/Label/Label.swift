nonisolated struct Label<Title,Icon>  where Title: View, Icon: View {
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