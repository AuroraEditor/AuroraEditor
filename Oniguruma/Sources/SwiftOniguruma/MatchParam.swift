//
//  MatchParam.swift
//  
//
//  Created by Gavin Mao on 3/27/21.
//

import Oniguruma

public class MatchParam {
    internal private(set) var rawValue: OpaquePointer!

    public init() {
        self.rawValue = onig_new_match_param()
    }

    deinit {
        onig_free_match_param(self.rawValue)
    }

    /**
     Set the fields to default values.
     */
    public func reset() {
        onig_initialize_match_param(self.rawValue)
    }

    /**
     Set the maximum number of match-stack depth of the `MatchParam`. `0` means unlimited.
     - Parameter newLimit: The new limit.
     */
    public func setMatchStackLimitSize(to newLimit: UInt) {
        onig_set_match_stack_limit_size_of_match_param(self.rawValue, OnigUInt(newLimit))
    }

    /**
    Set the retry limit count of a match process of the `MatchParam`.
     - Parameter newLimit: The new limit.
     */
    public func setRetryLimitInMatch(to newLimit: UInt) {
        onig_set_retry_limit_in_match_of_match_param(self.rawValue, OnigULong(newLimit))
    }

    /**
     Set the retry limit count in a search process of the `MatchParam`. `0` means unlimited.
     - Parameter newLimit: The new limit.
     */
    public func setRetryLimitInSearch(to newLimit: UInt) {
        onig_set_retry_limit_in_search_of_match_param(self.rawValue, OnigULong(newLimit))
    }

    /**
     Get or set the default value of maximum number of stack size, `0` means unlimited.
     */
    public static var defaultMatchStackLimitSize: UInt {
        get {
            onigQueue.sync {
                UInt(onig_get_match_stack_limit_size())
            }
        }

        set {
            _ = onigQueue.sync {
                onig_set_match_stack_limit_size(OnigUInt(newValue))
            }
        }
    }

    /**
     Get or set the default value of retry counts in a matching process., `0` means unlimited.
     The initial default value is `10000000`.
     */
    public static var defaultRetryLimitInMatch: UInt {
        get {
            onigQueue.sync {
                UInt(onig_get_retry_limit_in_match())
            }
        }

        set {
            _ = onigQueue.sync {
                onig_set_retry_limit_in_match(OnigULong(newValue))
            }
        }
    }

    /**
     Get or set the default value of retry counts in a matching process., `0` means unlimited.
     */
    public static var defaultRetryLimitInSearch: UInt {
        get {
            onigQueue.sync {
                UInt(onig_get_retry_limit_in_search())
            }
        }

        set {
            _ = onigQueue.sync {
                onig_set_retry_limit_in_search(OnigULong(newValue))
            }
        }
    }
}
