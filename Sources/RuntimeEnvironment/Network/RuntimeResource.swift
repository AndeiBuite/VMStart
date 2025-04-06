//
//  RuntimeResource.swift
//  VMStart
//
//  Created by Andei Buite on 2025/04/05.
//

/// Represents a resource that provides a runtime environment.
/// Each resource contains metadata and can be fetched to a specified destination.
public protocol RuntimeResource
{
    var metadata:Runtime.Metadata { get }
    
    func fetch(to destination:Destination) async throws -> Runtime
}
