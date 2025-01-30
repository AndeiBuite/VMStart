//
//  Tests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/11.
//

import Testing
import Foundation
@testable import VMStart

extension Runtime
{
    func executeArchive(atPath archive:URL, withProperties properties:[Property]) throws -> VirtualMachine
    {
        let task = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        let stdinPipe = Pipe()
        
        task.executableURL = self.structure.executable
        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe
        task.standardInput = stdinPipe
        task.arguments = properties
        
        try task.run()
        
        return VirtualMachine(runtime:self, properties:properties, process:task)
    }
}
