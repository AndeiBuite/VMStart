//
//  Runtime.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/05.
//

import Foundation

public struct Runtime
{
    public var metadata:RuntimeMetadata
    public var files:RuntimePackage
}

public protocol RuntimeMetadata
{
    /// the company or organization responsible for the distribution
    var implementor:String { get }
    
    /// the specific version of the runtime distribution.
    var implementorVersion:String { get }
    
    /// the version of the Java runtime itself.
    var javaRuntimeVersion:String { get }
    
    /// more simpliy formatted `javaRuntimeVersion`.
    var javaVersion:String { get }
    
    /// the release date of the Java version.
    var javaVersionDate:String? { get }
    
    /// the version of the standard C library used, it will marked as “default” in most case.
    var libc:String { get }
    
    /// list of all the Java modules included in this build.
    var modules:[String] { get }
    
    /// the os architecture which the runtime adapted
    var osARCH:String { get }
    
    /// the operating system which the runtime adapted
    var osNAME:String { get }
    
    /// source or version control reference (it might be a git commit hash).
    var source:String? { get }
}

public protocol RuntimePackage
{
    var executable:URL { get }
    
    var binFolder:URL? { get }
    
    var libFolder:URL? { get }
    
    var jmodsFolder:URL? { get }
    
    var confFolder:URL? { get }
    
    var legalFolder:URL? { get }
}
