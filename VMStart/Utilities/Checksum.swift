//
//  Checksum.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/08.
//

import CryptoKit

/// Represents a checksum, which is a value used to verify whether data has been altered or corrupted.
public protocol Checksum<Protected>
{
    associatedtype Protected
    
    func verify(_ data:Protected) async throws -> Bool
}

public struct SHA256Checksum: Checksum
{
    public typealias Protected = Data
    
    private let digest:SHA256.Digest
    
    public func verify(_ data:Data) async throws -> Bool
    {
        return SHA256.hash(data:data) == self.digest
    }
    
    init(inner digest:SHA256.Digest)
    {
        self.digest = digest
    }
    
    init(computes subject:Data)
    {
        self.digest = SHA256.hash(data:subject)
    }
}
