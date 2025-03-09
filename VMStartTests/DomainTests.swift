//
//  DomainTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/09.
//

import Testing
@testable import VMStart

@Test func domainTests() async throws
{
    let example = Domain(withString:"com.example")
    let subdomain = Domain(withString:"com.example.subdomain")
    
    assert(example.isParentTo(another:subdomain) == true, "example should be parent of subdomain, but test fails")
    assert(subdomain.isChildTo(another:example) == true, "subdomain should be child of example, but test fails")
}
