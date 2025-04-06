//
//  Compatibility.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/21.
//

/// Represents how compatible a runtime package is with a specific environment or requirement.
/// Compatibility is measured as a weighted average of individual factors.
open class RuntimeCompatibility: WeightedAverageNumber
{
    public typealias AverageFactor = Factor
    
    open var inner:Double
    
    public init(inner:Double)
    {
        self.inner = inner
    }
    
    public required convenience init(_ factors:[Factor])
    {
        func normalize(_ target:[Factor])-> [Factor]
        {
            let total = target.reduce(0.0) { $0 + $1.weight.double }
            guard total > 0 else { return target }  // prevent division by zero
            
            let scalingFactor = 1.0 / total
            return target.map { factor in
                let newNumber = UInt32(Double(factor.weight.number) * scalingFactor)
                return Factor(factor.degree, weight:Percentage(newNumber, of: factor.weight.maximum))
            }
        }
        let factors = normalize(factors)
        var sum:Double = 0.0
        let count = Double(factors.count)
        for factor in factors.lazy
        {
            sum += factor.degree * factor.weight.double
        }
        self.init(inner:sum / count)
    }
    
    public static func < (lhs:RuntimeCompatibility, rhs:RuntimeCompatibility)-> Bool
    {
        return lhs.inner < rhs.inner
    }
    
    public static func == (lhs:RuntimeCompatibility, rhs:RuntimeCompatibility)-> Bool
    {
        return lhs.inner == rhs.inner
    }
    
    /// Represents a single compatibility factor with a degree (score) and its associated weight.
    open class Factor: Weighted
    {
        public var weight:Percentage
        public var degree:Double
        
        init(_ degree:Double, weight:Percentage)
        {
            self.weight = weight
            self.degree = degree
        }
    }
}

/// Defines an entity that inspects runtime metadata and produces a compatibility factor.
public protocol RuntimeInspector
{
    func examine(_ subject:Runtime.Metadata)-> RuntimeCompatibility.Factor
}

/// Provides a readable string representation of the compatibility score.
extension RuntimeCompatibility: CustomStringConvertible
{
    public var description:String
    {
        return "RuntimeCompatibility[\(inner)]"
    }
}
