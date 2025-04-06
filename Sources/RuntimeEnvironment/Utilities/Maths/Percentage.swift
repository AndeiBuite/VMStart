//
//  Percentage.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/21.
//

/// Represents a percentage value based on a numerator (`number`) and a denominator (`maximum`).
/// Used for comparing or displaying relative proportions.
open class Percentage
{
    open var maximum:UInt32
    open var number:UInt32
    
    init(_ number:UInt32, of maximum:UInt32)
    {
        self.number = number
        self.maximum = maximum
    }
}

extension Percentage
{
    /// Returns the percentage as a `Double` between 0.0 and 1.0
    public var double:Double
    {
        return Double(number) / Double(maximum)
    }
}

extension Percentage: Comparable, Equatable
{
    public static func < (lhs:Percentage, rhs:Percentage) -> Bool
    {
        return lhs.double < rhs.double
    }
    
    public static func == (lhs:Percentage, rhs:Percentage) -> Bool
    {
        return lhs.double == rhs.double
    }
}

extension Percentage
{
    /// Creates a new percentage by averaging a list of other `Percentage` instances,
    /// normalized to a 100-point scale.
    convenience init(mixes instances:[Percentage])
    {
        let maximum:Double = 100.0
        var number:UInt32 = 0
        for instance in instances
        {
            let scale:Double = Double(instance.maximum) / maximum
            number += UInt32(Double(instance.number) * scale)
        }
        self.init(number, of:UInt32(maximum))
    }
}

extension Percentage: CustomStringConvertible
{
    /// Returns a string description of the percentage.
    /// Uses ‰ for very small values, % for mid-range values, and a plain double otherwise.
    public var description:String
    {
        let double = self.double
        if double < 0.1
        {
            return "\(double * 100)‰"
        }
        else if double < 1
        {
            return "\(double * 10)%"
        }
        else
        {
            return "\(double)"
        }
    }
}

extension Percentage
{
    /// Predefined percentage values representing 100% and 0%.
    public static var maximum:Percentage = Percentage(1, of:1)
    public static var minimum:Percentage = Percentage(0, of:1)
}
