import oniguruma
import Dispatch

/**
 The dispatch queue used to execute thread unsafe operation like `initialize`  `Regex.init`.
 */
internal let onigQueue = DispatchQueue(label: "SwiftOnig")

/**
 Get the oniguruma library version string.
 */
public func version() -> String {
    return String(cString: onig_version())
}

/**
 Get the oniguruma library copyright string.
 */
public func copyright() -> String {
    return String(cString: onig_copyright())
}

/**
 Initialize the library.
 - Note: You have to call it explicitly.
 - Parameter encodings: Encodings used in the application.
 */
public func initialize<S: Sequence>(encodings: S) throws where S.Element == Encoding {
    try onigQueue.sync {
        onig_initialize(nil, 0)
        for encoding in encodings {
            try callOnigFunction {
                onig_initialize_encoding(encoding.rawValue)
            }
        }
    }
}

/**
 The use of this library is finished.
 - Note: It is not allowed to use regex objects which created before `uninitialize` call.
 */
public func uninitialize() {
    onigQueue.sync {
        _ = onig_end()
    }
}

/**
 Call oniguruma functions.
 - Parameters:
    - body: The closure calling oniguruma library functions
 - Throws:
    `OnigError` if `body` returns code not in following normal return codes:
    [`ONIG_NORMAL`, `ONIG_MISMATCH`, ``ONIG_NO_SUPPORT_CONFIG`, `ONIG_ABORT`]
 */
@discardableResult
internal func callOnigFunction(_ body: () throws -> OnigInt) throws -> OnigInt {
    let result = try body()

    switch result {
    case _ where result > 0:
        return result
    case ONIG_NORMAL, ONIG_MISMATCH, ONIG_NO_SUPPORT_CONFIG, ONIG_ABORT:
        return result
    default:
        throw OnigError(onigErrorCode: result)
    }
}
