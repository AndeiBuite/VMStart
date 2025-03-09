//
//  OpenJDK.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/27.
//

import Foundation
import CryptoKit
internal import SwiftSoup

public final class OpenJDKRuntimeLibrary: RuntimeLibrary
{
    private var analyzed:[(Runtime,Checksum<Data,SHA256>?)] = []
    private var lastRefreshingHush:Int = 0
    
    public typealias Configuration = [Configs]
    
    private func fetchWebsitePage() throws -> String
    {
        guard let websiteLink = URL(string: "https://jdk.java.net/archive/") else
        {
            throw Errors.resourcesFeatching
        }
        let semaphore = DispatchSemaphore(value:0)
        var content:Data? = nil
        URLSession.shared.dataTask(with:websiteLink)
        {
            data, _, _ in
            content = data
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout:DispatchTime.distantFuture)
        guard let content = content else
        {
            throw Errors.resourcesFeatching
        }
        guard let result = String(data:content, encoding: .utf8) else
        {
            throw Errors.resourcesFeatching
        }
        return result
    }
    
    public func refresh() throws -> Self
    {
        let websiteContent = try fetchWebsitePage()
        let websitePageHush = websiteContent.hashValue
        if lastRefreshingHush == websitePageHush
        {
            return self
        }
        lastRefreshingHush = websitePageHush
        
        let releasesList = try SwiftSoup.parse(websiteContent).select("table.builds tr")
        var lastVersionNumberFound:String? = nil
        for (index, row) in releasesList.enumerated()
        {
            let children = row.children()
            switch children.count
            {
                case 1: lastVersionNumberFound = try row.text(); continue
                case 3:
                    guard let downloadLinkString = try children.select("td a[href]").first()?.attr("href") else { continue }
                    guard let sha256LinkString = try children.select("span.sha a[href]").first()?.attr("href") else { continue }
                    var systemType:Runtime.Metadata.SystemType? = switch try children[0].text().lowercased()
                    {
                        case "windows": .windows
                        case "mac":     .darwin
                        case "linux":   .linux
                        default: nil
                    }
                    var systemArch:Runtime.Metadata.SystemArch = switch try children[1].text().lowercased()
                    {
                        case "aarch64": .aarch64
                        default:        .x86_64
                    }
                    guard let lastVersionNumberFound = lastVersionNumberFound else { continue }
                    let versionNumber = VersionNumber(lastVersionNumberFound)
                    guard let systemType = systemType else { continue }
                    guard let downloadLink = URL(string: downloadLinkString) else { continue }
                    let metadata = Runtime.Metadata(
                        javaVersion: versionNumber,
                        systemArch: systemArch,
                        systemType: systemType
                    )
                    let package = Runtime.Package.compressed(downloadLink)
                    let runtime = Runtime(metadata:metadata, files:package)
                    // guard let sha256Link = URL(string: sha256LinkString) else { continue }
                    analyzed.append((runtime,nil))
                default: throw Errors.invalidFetchData
            }//^switch children.count
        }//^for each releaseListItems
        return self
    }
    
    public func search(requirements:[any RuntimeInspector], config:[Configs] = Configs.default) throws -> (Runtime,RuntimeHealthIndex)
    {
        <#code#>
    }
    
    public func searchAll(requirements:[any RuntimeInspector], config:[Configs] = Configs.default) throws -> any Sequence<(Runtime,RuntimeHealthIndex)>
    {
        <#code#>
    }
    
    public enum Configs
    {
        case refreshBeforeSreaching(Bool)
        
        public static var `default`:[Configs] =
        [
            .refreshBeforeSreaching(true)
        ]
    }
    
    public enum Errors: Error
    {
        case resourcesFeatching
        case invalidFetchData
    }
}
