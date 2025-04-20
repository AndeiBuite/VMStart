//
//  Resources.swift
//  VMStart
//
//  Created by Andei Buite on 2025/04/18.
//

public struct Resource
{
    public var identifier:UUID
    public var checksum:any Checksum<Data>
}
