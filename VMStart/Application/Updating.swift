//
//  Updating.swift
//  VMStart
//
//  Created by Andei Buite on 2025/04/18.
//

public protocol UpdatingServer
{
    func compare(between version:VersionNumber, and another:VersionNumber) async throws -> [ResourcesDifference]
    
    func fetch(for resource:UUID) async throws -> Data
}

public enum ResourcesDifference
{
    case new(Resource)
    case removed(identifier:UUID)
}
