//
//  VersionNumber.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/05.
//

open class VersionNumber: Hashable
{
    open var major: UInt32 = 0
    open var minor: UInt32 = 0
    open var patch: UInt32 = 0
    
    init(_ major:UInt32, _ minor:UInt32, _ patch:UInt32)
    {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public static func == (lhs:VersionNumber, rhs:VersionNumber) -> Bool
    {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
    }
}

public typealias Ver = VersionNumber

extension VersionNumber
{
    convenience init(_ versionNumberString:String)
    {
        let components = versionNumberString.split(separator: ".").map { UInt32($0) ?? 0 }
        
        let major = components.count > 0 ? components[0] : 0
        let minor = components.count > 1 ? components[1] : 0
        let patch = components.count > 2 ? components[2] : 0
        
        self.init(major, minor, patch)
    }
}

extension VersionNumber: CustomStringConvertible
{
    public var description: String
    {
        return "[\(major).\(minor).\(patch)]"
    }
}

extension VersionNumber: Comparable
{
    public static func < (lhs: VersionNumber, rhs: VersionNumber) -> Bool
    {
        if lhs.major < rhs.major { return true } // smaller major makes lhs < rhs
        if lhs.major > rhs.major { return false }// bigger major makes lhs > rhs
        if lhs.minor < rhs.minor { return true } // when major equals, smaller minor makes lhs < rhs
        if lhs.minor > rhs.minor { return false }// when major equals, bigger minor makes lhs > rhs
        if lhs.patch < rhs.patch { return true } // when both major minor equals, samller patch makes lhs < rhs
        if lhs.patch > rhs.patch { return false }//when both major minor equals, bigger patch makes lhs > rhs
        return false    // all fields are same... lhs must not samller than rhs
    }
}
