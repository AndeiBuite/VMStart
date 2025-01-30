//
//  VirtualMachine.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/05.
//

public typealias Property = String

public struct VirtualMachine
{
    public var runtime:Runtime
    public var properties:[Property]
    public var process:Process
}
