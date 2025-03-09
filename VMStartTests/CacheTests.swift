//
//  CacheTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/03.
//

import Foundation
import Testing
@testable import VMStart

@Test func cacheTest() throws
{
    var data = 0
    let _ = Cache(refreshTimeInterval: 1)
    {
        return data += 1
    }
    while data < 10
    {
        print(data)
        wait(seconds: 1)
    }
}

func wait(seconds: TimeInterval)
{
    let until = Date().addingTimeInterval(seconds)
    while Date() < until
    {
        RunLoop.current.run(mode: .default, before: until)
    }
}
