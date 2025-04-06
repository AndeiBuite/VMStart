//
//  Domain.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/09.
//

public struct Domain
{
    public var sections:[String]
    
    init(sections: [String])
    {
        self.sections = sections
    }
}

extension Domain
{
    convenience init(withString domain:String)
    {
        self.init(sections: domain.split(separator: ".").map{ String($0) })
    }
}

extension Domain: CustomStringConvertible
{
    public var description: String
    {
        return sections.joined(separator: ".")
    }
}

extension Domain: Equatable
{
    public static func == (lhs: Domain, rhs: Domain) -> Bool
    {
        return lhs.sections == rhs.sections
    }
}

extension Domain: Hashable
{
    
}

extension Domain
{
    public var parent:Domain
    {
        Domain(sections: Array(sections).dropLast())
    }
    
    public func isParentTo(another:Domain) -> Bool
    {
        for (index,item) in sections.enumerated()
        {
            if item != another.sections[index] { return false }
        }
        return true
    }
    
    public func isChildTo(another:Domain) -> Bool
    {
        for (index,item) in another.sections.enumerated()
        {
            if item != sections[index] { return false }
        }
        return true
    }
}
