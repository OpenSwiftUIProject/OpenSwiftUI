public protocol _Test {
    func setUpTest()
    func tearDownTest()
}

extension _Test {
    public func setUpTest() {}
    public func tearDownTest() {}
}
