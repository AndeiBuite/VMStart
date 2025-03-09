//
//  RuntimeInspectionTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/08.
//

import Testing
@testable import VMStart

private struct RuntimeInspectionTests
{
    private struct RuntimeHealthIndexTests
    {
        @Test func comparasionTest() async throws
        {
            let smaller = RuntimeHealthIndex(-3)
            let bigger = RuntimeHealthIndex(+3)
            let another = RuntimeHealthIndex(+3)
            
            assert(smaller < bigger)
            assert(another == bigger)
            assert(bigger > smaller)
        }
    }
}
