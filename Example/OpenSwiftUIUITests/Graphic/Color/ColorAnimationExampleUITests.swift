 //
 //  ColorAnimationExampleUITests.swift
 //  OpenSwiftUIUITests

 import Testing
 import SnapshotTesting

 @MainActor
 @Suite(.snapshots(record: .never, diffTool: diffTool))
 struct ColorAnimationExampleUITests {
     @Test
     func colorAnimationExample() async {
         struct ContentView: View {
             @State private var showRed = false
             var body: some View {
                 VStack {
                     Color(platformColor: showRed ? .red : .blue)
                         .frame(width: showRed ? 200 : 400, height: showRed ? 200 : 400)
                 }
                 .animation(.easeInOut(duration: 2), value: showRed)
                 .onAppear {
                     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                         withAnimation {

                             showRed.toggle()
                         }
                     }
                 }
             }
         }
         openSwiftUIAssertSnapshot(of: ContentView())
     }
 } 
