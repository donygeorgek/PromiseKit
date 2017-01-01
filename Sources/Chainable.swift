/**
 Makes the signature for chainable operations simpler, also
 enables us to avoid entire classes of @unavailable annotations,
 see PromiseKit 4 for examples of what has been cleaned up.
 
 Conversion of everything to a promise is relatively cheap, since
 we have an optimized—lock free—path for `SealedState`.
 
 However ideally we’d avoid that if possible FIXME
*/
public protocol Chainable {
    associatedtype Wrapped

    // convert this type into a `Promise`
    var promise: Promise<Wrapped> { get }
}

internal extension Chainable {
    func pipe(to pipe: Pipe<Wrapped>) {
        promise.pipe(to: pipe)
    }
    var state: State<Wrapped> {
        return promise.state
    }
}

extension Promise: Chainable {
    public var promise: Promise { return self }
}

extension Bool: Chainable {
    public var promise: Promise<Bool> { return Promise(self) }
}

extension Int: Chainable {
    public var promise: Promise<Int> { return Promise(self) }
}

extension UInt32: Chainable {
    public var promise: Promise<UInt32> { return Promise(self) }
}

extension String: Chainable {
    public var promise: Promise<String> { return Promise(self) }
}

extension Data: Chainable {
    public var promise: Promise<Data> { return Promise(self) }
}

extension Optional: Chainable {
    public var promise: Promise<Optional> { return Promise(self) }
}

extension AnyPromise: Chainable {
    public var promise: Promise<Any?> { return Promise(state: state) }
}

extension Result: Chainable {
    public var promise: Promise<T> { return Promise(self) }
}

//TODO sucks
public protocol Promisey {}
extension Promise: Promisey {}
extension AnyPromise: Promisey {}

extension Optional where Wrapped: Promisey, Wrapped: Chainable {
    public var promise: Wrapped {
        switch self {
        case .some(let Wrapped):
            return Wrapped
        case .none:
            fatalError("Cannot figure this out")  //FIXME!
        }
    }
}
