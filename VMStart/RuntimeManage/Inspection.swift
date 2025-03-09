//
//  Inspection.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/07.
//

public protocol RuntimeInspector
{
    func examine(_ subject:Runtime)-> RuntimeHealthIndex
}

public struct RuntimeHealthIndex
{
    public private(set) var isHealth:Bool
    public private(set) var weight:UInt32
    
    init(isHealth: Bool, weight: UInt32)
    {
        self.isHealth = isHealth
        self.weight = weight
    }
}

extension RuntimeHealthIndex: Comparable,Equatable
{
    init(_ int:Int32)
    {
        self.isHealth = !(int < 0)
        self.weight = UInt32(abs(int))
    }
    
    public var int32:Int32
    {
        return if isHealth { Int32(weight) } else { -Int32(weight) }
    }
    
    public static func < (lhs:RuntimeHealthIndex, rhs:RuntimeHealthIndex) -> Bool
    {
        return lhs.int32 < rhs.int32
    }
    
    public static func += (lhs:inout Self, rhs:Self)
    {
        let lhs_int32 = lhs.int32
        let rhs_int32 = rhs.int32
        
        lhs = Self(lhs_int32 + rhs_int32)
    }
}

public final class RuntimeJavaVersionInspector: RuntimeInspector
{
    private var required:Range<VersionNumber>
    
    public func examine(_ subject:Runtime)-> RuntimeHealthIndex
    {
        if required.contains(subject.metadata.javaVersion)
        {
            return RuntimeHealthIndex(+1)
        }
        return RuntimeHealthIndex(-1)
    }
    
    init(range required:Range<VersionNumber>)
    {
        self.required = required
    }
    
    convenience init(from start:VersionNumber, to ending:VersionNumber)
    {
        self.init(range:Range(uncheckedBounds:(start,ending)))
    }
}

public final class RuntimePlatfromInspector: RuntimeInspector
{
    private var systemType:RuntimeMetadataSystemType
    private var systemArch:RuntimeMetadataSystemArchitechture
    
    public func examine(_ subject:Runtime)-> RuntimeHealthIndex
    {
        let it = subject.metadata
        if it.systemType == systemType && it.systemArch == systemArch
        {
            return RuntimeHealthIndex(+1)
        }
        return RuntimeHealthIndex(-1)
    }
    
    init(_ systemType:RuntimeMetadataSystemType, _ systemArch:RuntimeMetadataSystemArchitechture)
    {
        self.systemType = systemType
        self.systemArch = systemArch
    }
}

public final class RuntimePackageInspctor: RuntimeInspector
{
    public func examine(_ subject:Runtime) -> RuntimeHealthIndex
    {
        <#code#>
    }
}
