//
//  Manager.swift
//  VMStart
//
//  Created by Andei Buite on 2025/03/22.
//

public final class RuntimeManager
{
    public var local:LocalRuntimeLibrary
    public var foriegns:[NetworkRuntimeLibrary]
    
    init(foriegns:[NetworkRuntimeLibrary]) throws
    {
        guard let local = try? LocalRuntimeLibrary(level: .system) else
        {
            throw InitliazingErrors.creatingLocalRuntimeLibrary
        }
        self.local = local
        self.foriegns = foriegns
    }
    
    public enum InitliazingErrors: Error
    {
        case creatingLocalRuntimeLibrary
    }
}
