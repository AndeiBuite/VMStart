//
//  PercentageTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/21.
//

import Testing
@testable import VMStart

@Test func percentageToDoubleTest() async throws
{
    assert(Percentage(30, of:100).double == 0.3)
    assert(Percentage(1 , of: 10).double == 0.1)
    assert(Percentage(10, of:  1).double == 10.0)
    assert(Percentage(5, of:10) == Percentage(5, of:10))
    assert(Percentage(1, of:10) > Percentage(5, of:100))
    assert(Percentage(3, of:10) < Percentage(8, of:  1))
}
