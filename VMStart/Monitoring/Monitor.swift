//
//  Monitor.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/22.
//

public protocol VirtualMachineMonitor
{
    associatedtype Monitored
    
    func fetch() async throws -> Monitored
}
