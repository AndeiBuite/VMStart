//
//  VersionNumberTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/11.
//

import Testing
@testable import VMStart

@Test func comparingTest() async throws
{
    let samller = Ver("10.9.0")
    let bigger = Ver("15.2.1")
    let another = Ver("10.9.0")
    
    assert((samller < bigger) == true)
    assert((samller > bigger) == false)
    assert((samller == another) == true)
    assert((bigger == another) == false)
}
