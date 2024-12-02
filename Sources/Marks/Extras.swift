
extension Optional {
    mutating func get(initialValue value: @autoclosure () -> Wrapped) -> Wrapped {
        if let self {
            return self
        } else {
            let it = value()
            self = it
            return it
        }
    }
}
