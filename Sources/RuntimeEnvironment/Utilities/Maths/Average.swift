//
//  Average.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/21.
//

/// A numeric type that can be computed as the average of a collection of factors.
/// The factors can be of any type that the conforming type supports.
public protocol AverageNumber: Comparable, Equatable
{
    associatedtype AverageFactor
    
    init(_ factors:[AverageFactor])
}

/// A type of average number where each factor has an associated weight.
/// The average is calculated based on both the values and their weights.
public protocol WeightedAverageNumber: AverageNumber where AverageFactor:Weighted
{
    
}

/// A type representing a value that contributes to a weighted average,
/// with an associated weight indicating its influence.
public protocol Weighted
{
    var weight:Percentage { get }
}
