//
//  Runtime.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/07.
//

import Foundation
import CryptoKit

public struct Runtime: Hashable
{
    public var metadata:Metadata
    public var files:Package
    
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
        
        public enum SystemType: Hashable
        {
            case darwin
            case windows
            case linux
        }
        
        public enum SystemArch: Hashable
        {
            case x86_64
            case aarch64
        }
        
        public struct Implementor: Hashable
        {
            public private(set) var domain:Domain
            public private(set) var name:String
            
            init(_ domain: Domain, _ name: String)
            {
                self.domain = domain
                self.name = name
            }
        }
    }
    
    public enum Package: Hashable
    {
        case compressed(URL)
        case structure(executable:URL, homeFolder:URL, bundle:URL)
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
    public static var oracle = Runtime.Metadata.Implementor(Domain(withString:"com.oracle"), "Oracle Corporation")
    public static var amazon = Runtime.Metadata.Implementor(Domain(withString:"com.amazon.aws"), "Amazon.com Inc.")
    public static var azul = Runtime.Metadata.Implementor(Domain(withString:"com.azul"), "Azul Systems, Inc.")
    public static var bellSoft = Runtime.Metadata.Implementor(Domain(withString:"com.bell.sw"), "BellSoft")
    
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
                    default: Implementor(Domain(withString:"unknown"), String(value))
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
    
    public enum AnalyzingErrors: Error
    {
        case illegalReleaseInfoFormat
        case missingNeccessaryKeys
        case unexpectedValueToSomeKey
    }
}
