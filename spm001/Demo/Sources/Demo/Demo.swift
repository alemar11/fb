public enum MyError: Error {
  case noOutput
  case fail
}

open class Test<T> {
  public typealias Output = Result<T,Error>
  private(set) var output: Output = .failure(MyError.noOutput)

  public init() { }

  public func start() {
    run(completion: finish)
  }

  open func run(completion: @escaping (Output) -> Void) {
    preconditionFailure("Subclass it")
  }

  private func finish(result: Output) {
    self.output = result
  }
}
