/**
 Create a new pending promise by wrapping another asynchronous system.

 This initializer is convenient when wrapping asynchronous systems that
 use common patterns. For example:

     func fetchKitten() -> Promise<UIImage> {
         return PromiseKit.wrap { resolve in
             KittenFetcher.fetchWithCompletionBlock(resolve)
         }
     }

 - SeeAlso: Promise.init(resolvers:)
*/
public func wrap<T>(_ body: (@escaping (T?, Error?) -> Void) throws -> Void) -> Promise<T> {
    return Promise { pipe in
        try body { obj, err in
            if let err = err {
                pipe.reject(err)
            } else if let obj = obj {
                pipe.fulfill(obj)
            } else {
                pipe.reject(PMKError.invalidCallingConvention)
            }
        }
    }
}

/// For completion-handlers that eg. provide an enum or an error.
public func wrap<T>(_ body: (@escaping (T, Error?) -> Void) throws -> Void) -> Promise<T>  {
    return Promise { pipe in
        try body { obj, err in
            if let err = err {
                pipe.reject(err)
            } else {
                pipe.fulfill(obj)
            }
        }
    }
}

/// Some APIs unwisely invert the Cocoa standard for completion-handlers.
public func wrap<T>(_ body: (@escaping (Error?, T?) -> Void) throws -> Void) -> Promise<T> {
    return Promise { pipe in
        try body { err, obj in
            if let err = err {
                pipe.reject(err)
            } else if let obj = obj {
                pipe.fulfill(obj)
            } else {
                pipe.reject(PMKError.invalidCallingConvention)
            }
        }
    }
}

/// For completion-handlers with just an optional Error
public func wrap(_ body: (@escaping (Error?) -> Void) throws -> Void) -> Promise<Void> {
    return Promise { pipe in
        try body { error in
            if let error = error {
                pipe.reject(error)
            } else {
                pipe.fulfill()
            }
        }
    }
}

/// For completions that cannot error.
public func wrap<T>(_ body: (@escaping (T) -> Void) throws -> Void) -> Promise<T> {
    return Promise { pipe in
        try body{ pipe.fulfill($0) }
    }
}
