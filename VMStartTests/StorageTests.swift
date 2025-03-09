//
//  StorageTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/08.
//

import Testing
@testable import VMStart

private struct StorageTests
{
    private struct LocalRuntimeLibraryTest
    {
        @Test func creatingTest() async throws
        {
            let library = try LocalRuntimeLibrary(level: .system).refresh()
        }
    }
}
