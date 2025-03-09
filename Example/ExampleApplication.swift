//
//  ExampleApplication.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/09.
//

import VMStart

public struct ExampleApplication: Application
{
    public var applicationName:String = "ExampleApplication"
    public var mainClass:String = "com.example.Main"
    public var defaultArguments:[String] = []
    public var files:ApplicationFiles = .archive(path: URL(fileURLWithPath: "path/to/archive"))
}
