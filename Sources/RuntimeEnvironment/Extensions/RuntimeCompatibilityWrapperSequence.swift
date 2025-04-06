//
//  RuntimeCompatibilityWrapperSequence.swift
//  VMStart
//
//  Created by Andei Buite on 2025/04/04.
//

extension Sequence where Element == (any RuntimeResource,RuntimeCompatibility)
{
    public var best:(any RuntimeResource,RuntimeCompatibility)?
    {
        var cached:((any RuntimeResource)?,RuntimeCompatibility) = (nil,RuntimeCompatibility(inner:-1))
        for (runtimeRecource,compatibility) in self
        {
            if compatibility > cached.1
            {
                cached = (runtimeRecource,compatibility)
                continue
            }
        }
        guard let result = cached.0 else
        {
            return nil
        }
        return (result,cached.1)
    }
}
