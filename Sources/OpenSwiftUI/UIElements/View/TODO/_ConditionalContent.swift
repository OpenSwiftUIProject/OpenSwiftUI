@frozen
public struct _ConditionalContent<TrueContent, FalseContent> {
    @usableFromInline
    @frozen enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }

    @usableFromInline
    let storage: _ConditionalContent<TrueContent, FalseContent>.Storage
}

extension _ConditionalContent: View, PrimitiveView where TrueContent: View, FalseContent: View {
    @usableFromInline
    init(storage: _ConditionalContent<TrueContent, FalseContent>.Storage) {
        self.storage = storage
    }
//    public static func _makeView(view: _GraphValue<_ConditionalContent<TrueContent, FalseContent>>, inputs: _ViewInputs) -> _ViewOutputs
//    public static func _makeViewList(view: _GraphValue<_ConditionalContent<TrueContent, FalseContent>>, inputs: _ViewListInputs) -> _ViewListOutputs
//    public static func _viewListCount(inputs: _ViewListCountInputs) -> Swift.Int?
}
