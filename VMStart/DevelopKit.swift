//
//  DevelopKit.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/30.
//

public struct DevelopKit
{
    public var metadata:RuntimeMetadata
    public var files:DevelopKitPackage
}

public protocol DevelopKitPackage: RuntimePackage
{
    var libjli:URL? { get }
    var infoPlist:URL { get }
    var javac:URL { get }
    var includeFolder:URL { get }
}
