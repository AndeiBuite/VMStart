//
//  Runtime.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/07.
//

import Foundation

/// Represents a Java Runtime Environment (JRE) with its metadata and associated package structure.
public struct Runtime: Hashable
{
    public var metadata:Metadata
    public var files:Package
    
    /// Contains metadata about a Java runtime, such as version, architecture, and implementor.
    public struct Metadata: Hashable
    {
        public var javaVersion:VersionNumber
        public var systemArch:SystemArch
        public var systemType:SystemType
        public var implementor:Implementor?
        public var javaVersionDate:String?
        /// the version of the standard C library used, it will marked as “default” in most case.
        public var libc:String?
        public var modules:[String]?
        public var source:String?
        
        /// Enumerates the possible operating systems that a Java runtime can run on.
        public enum SystemType: Hashable
        {
            case darwin
            case windows
            case linux
        }
        
        /// Enumerates the possible system architectures supported by a Java runtime.
        public enum SystemArch: Hashable
        {
            case x86_64
            case aarch64
        }
        
        /// Represents the organization or entity that created the Java runtime.
        public struct Implementor: Hashable
        {
            public var domain:Domain
            public var name:String
        }
    }
    
    /// Represents the package structure of a Java runtime, including its executable and related folders.
    public struct Package: Hashable
    {
        public var executable:URL
        public var homeFolder:URL
        public var bundle:URL
    }
}

extension Runtime.Metadata.Implementor: Equatable
{
    public static func == (lhs:Runtime.Metadata.Implementor, rhs:Runtime.Metadata.Implementor) -> Bool
    {
        return lhs.domain == rhs.domain && rhs.name == lhs.name
    }
}

extension Runtime.Metadata.Implementor
{
    init(_ domain: String, _ name: String)
    {
        self.domain = Domain(domain)
        self.name = name
    }
}

extension Runtime.Metadata.Implementor
{
    public static var oracle = Runtime.Metadata.Implementor("com.oracle", "Oracle Corporation")
    public static var amazon = Runtime.Metadata.Implementor("com.amazon.aws", "Amazon.com Inc.")
    public static var azul = Runtime.Metadata.Implementor("com.azul", "Azul Systems, Inc.")
    public static var bellSoft = Runtime.Metadata.Implementor("com.bell.sw", "BellSoft")
    
    public func isVerified() -> Bool
    {
        func resolve(_ instance:Runtime.Metadata.Implementor) -> (Domain,String)
        {
            return (instance.domain,instance.name)
        }
        func matching(_ instance:Runtime.Metadata.Implementor) -> Bool
        {
            let domain = instance.domain
            let name = instance.name
            return (self.domain.isChildTo(another:domain) || self.domain == domain) && name == self.name
        }
        return matching(Self.amazon) || matching(Self.azul) || matching(Self.bellSoft) || matching(Self.oracle)
    }
}

extension Runtime.Metadata
{
    /// formatted like ["OS_NAME=\"Darwin\"","OS_ARCH=\"aarch64\""...]
    init(withReleaseInformation releaseInfo:[String]) throws
    {
        var javaVersion:VersionNumber? = nil
        var systemArch:Runtime.Metadata.SystemArch? = nil
        var systemType:Runtime.Metadata.SystemType? = nil
        var implementor:Implementor? = nil
        var javaVersionDate:String? = nil
        var libc:String? = nil
        var modules:[String]? = nil
        var source:String? = nil
        func split(_ line:String) throws -> (key:String.SubSequence,value:String.SubSequence)
        {
            let kv = line.split(separator:"=")
            if kv.count != 2
            {
                throw AnalyzingErrors.illegalReleaseInfoFormat
            }
            var value = kv[1]
            var quotationMarkCount = 0
            if value.hasPrefix("\"") { quotationMarkCount += 1; value.removeFirst() }
            if value.hasSuffix("\"") { quotationMarkCount += 1; value.removeLast() }
            if quotationMarkCount != 0 && quotationMarkCount != 2
            {
                throw AnalyzingErrors.illegalReleaseInfoFormat
            }
            return (kv[0],value)
        }
        for line in releaseInfo
        {
            let (key,value) = try split(line)
            switch key
            {
                case "JAVA_VERSION": javaVersion = Ver(String(value))
                case "OS_ARCH": systemArch = switch value
                    {
                    case "aarch64": .aarch64
                    case "x86_64": .x86_64
                    default: throw AnalyzingErrors.unexpectedValueToSomeKey
                }
                case "OS_NAME": systemType = switch value
                    {
                    case "Darwin": .darwin
                    case "Linux": .linux
                    case "Windows": .windows
                    default: throw AnalyzingErrors.unexpectedValueToSomeKey
                }
                case "IMPLEMENTOR": implementor = switch value
                    {
                    case "Oracle Corporation": .oracle
                    case "Amazon.com Inc.": .amazon
                    case "Azul Systems, Inc.": .azul
                    case "BellSoft": .bellSoft
                    case "": throw AnalyzingErrors.unexpectedValueToSomeKey
                    default: Implementor("unknown", String(value))
                }
                case "MODULES": modules = value.split(separator:" ").lazy.map{ String($0) }
                case "JAVA_VERSION_DATE": javaVersionDate = String(value)
                case "LIBC": libc = String(value)
                case "SOURCE": source = String(value)
                default: continue
            }
        }
        if javaVersion == nil || systemArch == nil || systemType == nil
        {
            throw AnalyzingErrors.missingNeccessaryKeys
        }
        self.javaVersion = javaVersion!
        self.systemArch = systemArch!
        self.systemType = systemType!
        self.implementor = implementor
        self.javaVersionDate = javaVersionDate
        self.libc = libc
        self.modules = modules
        self.source = source
    }
    
    /// Enumerates errors that can occur while analyzing the release information of a Java runtime.
    public enum AnalyzingErrors: Error
    {
        case illegalReleaseInfoFormat
        case missingNeccessaryKeys
        case unexpectedValueToSomeKey
    }
}

extension Runtime.Metadata: CustomStringConvertible
{
    /// Returns a string representation of the runtime's metadata, including implementor, version, system type, and architecture.
    public var description:String
    {
        let implementor:String = if let impl = self.implementor { impl.name } else { "UnkownImplementor" }
        return "[\(implementor):\(javaVersion) on \(systemType)+\(systemArch)]"
    }
}

/// Initializes a `Runtime.Package` using a JDK/JRE bundle URL and validates its structure.
extension Runtime.Package
{
    init(withBundleURL bundle:URL) throws
    {
        self.bundle = bundle
        self.homeFolder = bundle.appending(components:"Contents","Home")
        self.executable = homeFolder.appending(components:"bin","java")
        
        let fm = FileManager.default
        
        if !fm.fileExists(atPath:bundle.path())
        {
            throw Errors.bundleNotFound
        }
        if bundle.pathExtension != "jdk" && bundle.pathExtension != "jre"
        {
            throw Errors.mistakeBundlePathExtension
        }
        
        if !fm.fileExists(atPath:homeFolder.path()) || !fm.fileExists(atPath:executable.path())
        {
            throw Errors.brokenStructure
        }
    }
    
    /// Enumerates possible errors related to the Java runtime package structure.
    public enum Errors: Error
    {
        case bundleNotFound
        case mistakeBundlePathExtension
        case brokenStructure
    }
}

extension Runtime.Package: CustomStringConvertible
{
    /// Returns a string representation of the runtime package, including the bundle path.
    public var description:String
    {
        let bundlePath = self.bundle.path()
        return "[runtimePackage:(\(bundlePath))]"
    }
}

extension Runtime: CustomStringConvertible
{
    /// Returns a string representation of the `Runtime` instance, including its metadata and package details.
    public var description:String
    {
        return "Runtime(metadata=\(metadata),files=\(files)"
    }
}

/// Initializes a `Runtime` instance using a JDK/JRE bundle URL and analyzes its release information.
extension Runtime
{
    init(withBundleURL bundle:URL) throws
    {
        let fm = FileManager.default
        if !fm.fileExists(atPath:bundle.path()) { throw Errors.bundleNotFound }
        let releaseInfoFile = bundle.appending(components:"Contents","Home","release")
        if !fm.fileExists(atPath:releaseInfoFile.path()) { throw Errors.brokenBundlePackage }
        let releaseInfoFileContents = try String(contentsOf:releaseInfoFile, encoding: .utf8)
        let releaseInfo = releaseInfoFileContents.split(separator:"\n").map{ String($0) }
        
        self.metadata = try Runtime.Metadata(withReleaseInformation:releaseInfo)
        self.files = try Runtime.Package(withBundleURL:bundle)
    }
    
    public enum Errors: Error
    {
        case bundleNotFound
        case brokenBundlePackage
    }
}
