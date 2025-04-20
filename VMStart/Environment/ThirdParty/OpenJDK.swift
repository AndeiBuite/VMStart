//
//  OpenJDK.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/27.
//

import Foundation
import CryptoKit
internal import SwiftSoup

/// Represents a downloadable OpenJDK runtime resource with associated metadata.
public final class OpenJDKRuntimeResource: RuntimeResource
{
    /// Possible errors that can occur during OpenJDK resource operations.
    public enum Errors: Error
    {
        case badDestination
        case downloadingCachesAccess
        case requestNetwork
    }
    
    public var link:URL
    public var metadata:Runtime.Metadata
    
    /// Downloads the OpenJDK runtime resource to the specified destination and returns a `Runtime` instance.
    public func fetch(to destination:Destination) async throws -> Runtime
    {
        // Check whether the destination is a valid directory to which files can be copied.
        var isDir:ObjCBool = false
        let exsits = FileManager.default.fileExists(atPath:destination.path.path(), isDirectory:&isDir)
        if !exsits || !isDir.boolValue
        {
            throw Errors.badDestination
        }
        //TODO: fetch openJDK runtime resources
        let files = try Runtime.Package(withBundleURL:URL(fileURLWithPath:"/Library/Java/JavaVirtualMachines/zulu_17_FX.jdk"))
        return Runtime(metadata:metadata, files:files)
    }
    
    init(link:URL, metadata:Runtime.Metadata)
    {
        self.link = link
        self.metadata = metadata
    }
}

/// A library that fetches and analyzes OpenJDK runtime resources from jdk.java.net.
public final class OpenJDKRuntimeLibrary: NetworkRuntimeLibrary
{
    private var analyzed:[OpenJDKRuntimeResource] = []
    private var lastRefreshingHush:Int = 0
    
    /// Downloads the raw HTML content of the OpenJDK archive page.
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
    
    /// Parses the OpenJDK archive page and updates the internal list of runtime resources.
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
        for (_, row) in releasesList.enumerated()
        {
            let children = row.children()
            switch children.count
            {
                case 1: lastVersionNumberFound = try row.text(); continue
                case 3:
                    guard let downloadLinkString = try children.select("td a[href]").first()?.attr("href") else { continue }
                    guard let sha256LinkString = try children.select("span.sha a[href]").first()?.attr("href") else { continue }
                    let systemType:Runtime.Metadata.SystemType? = switch try children[0].text().lowercased()
                    {
                        case "windows": .windows
                        case "mac":     .darwin
                        case "linux":   .linux
                        default: nil
                    }
                    let systemArch:Runtime.Metadata.SystemArch = switch try children[1].text().lowercased()
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
                    let result = OpenJDKRuntimeResource(link:downloadLink, metadata:metadata)
                    analyzed.append(result)
                default: throw Errors.invalidFetchData
            }//^switch children.count
        }//^for each releaseListItems
        return self
    }
    
    /// Searches for compatible runtime resources based on provided inspection requirements.
    public func search(requirements:[any RuntimeInspector]) throws -> any Sequence<(any RuntimeResource,RuntimeCompatibility)>
    {
        var result:[(any RuntimeResource,RuntimeCompatibility)] = []
        for item in analyzed
        {
            var factors:[RuntimeCompatibility.Factor] = []
            for inspector in requirements
            {
                factors.append( inspector.examine(item.metadata) )
            }
            let compatibility = RuntimeCompatibility(factors)
            if compatibility.inner < 0 { continue }
            result.append((item,compatibility))
        }
        return result
    }
    
    /// Errors related to fetching and parsing OpenJDK runtime information.
    public enum Errors: Error
    {
        case resourcesFeatching
        case invalidFetchData
        case noneMatchFound
    }
}
