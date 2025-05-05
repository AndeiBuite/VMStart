//
//  ProcessTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/05/02.
//

import Foundation
import Testing
@testable import VMStart

private struct ProcessBuildingTests
{
    @Test func building() async throws
    {
        let process = Process()
        
        process.executableURL = URL(fileURLWithPath:"/bin/echo")
        process.arguments = ["Hello, World!"]
        
        try process.run()
    }
}

private struct ProcessDispatchTests
{
    @Test func suspending() async throws
    {
        let process = Process()
        
        process.executableURL = URL(fileURLWithPath:"/bin/cat")
        process.arguments = ["/etc/paths"]
        
        try process.run()
        process.suspend()
        Task
        {
            sleep(5)
            process.resume()
        }
        process.waitUntilExit()
    }
}
