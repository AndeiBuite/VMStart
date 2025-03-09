//
//  Downloader.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/10.
//

import Foundation

public protocol Downloader
{
    func download(_ task:DownloadTask, autoStart resume:Bool) throws -> URL
    func downloadFiles(_ tasks:[DownloadTask], autoStart resume:Bool) throws -> [URL]
}

public struct DownloadTask
{
    public var url:URL
    public var destination:DownloadDestination
}

public enum DownloadDestination
{
    case renamed(path:URL)
    case moving(folder:URL)
}
