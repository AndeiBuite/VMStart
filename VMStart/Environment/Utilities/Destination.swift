//
//  Destination.swift
//  VMStart
//
//  Created by Andei Buite on 2025/04/06.
//

/// The destination of a redirected item. There are two cases: `hosted(folder: URL)` and `renamed(URL)`.
///
/// - `hosted(folder: URL)`: The item is moved or copied to a folder while keeping its original file name.
/// - `renamed(URL)`: The item is moved or copied to a new path, possibly with a new file name.
public enum Destination
{
    case hosted(folder:URL)
    case renamed(URL)
}

extension Destination
{
    public var path:URL
    {
        return switch self
        {
            case .hosted(let folder): folder
            case .renamed(let url): url
        }
    }
}
