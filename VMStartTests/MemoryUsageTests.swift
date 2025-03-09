//
//  MemoryUsageTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/03.
//

import Foundation
import Testing
import Darwin
@testable import VMStart

private typealias KB = UInt32

private let memoryUsgaeCache: Cache<KB> = Cache(refreshTimeInterval: 10)
{
    return 45
}

@Test func printUnitedMemoryUsageTest() throws
{
    print(memoryUsgaeCache)
}
