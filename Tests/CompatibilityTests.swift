//
//  CompatibilityTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/22.
//

import Testing
@testable import VMStart

@Test private func test() async throws
{
    let factors:[RuntimeCompatibility.Factor] =
    [
        RuntimeCompatibility.Factor(-10, weight:Percentage.maximum),
        RuntimeCompatibility.Factor(+10, weight:Percentage.minimum),
    ]
    
    let compatibility:RuntimeCompatibility = RuntimeCompatibility(factors)
    
    print(compatibility)
}
