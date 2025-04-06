//
//  Checksum.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/08.
//

import CryptoKit

public class Checksum<Protected,Algorithm> where Protected:Verifiable, Algorithm:DigestCalculator
{
    public var digestCalculator:Algorithm
    public var checksum:Data
    
    public func verificate(subject:Protected)-> Bool
    {
        return digestCalculator.examine(subject.data) == checksum
    }
    
    init(_ checksum:Data, calculator digestCalculator:Algorithm)
    {
        self.checksum = checksum
        self.digestCalculator = digestCalculator
    }
}

public protocol Verifiable
{
    var data:Data { get }
}

public protocol DigestCalculator
{
    func examine(_ subject:Data)-> Data
}

extension Data: Verifiable
{
    public var data:Data { return self }
}

extension SHA256: DigestCalculator
{
    public func examine(_ subject:Data)-> Data
    {
        return Data(Self.hash(data:subject))
    }
}
