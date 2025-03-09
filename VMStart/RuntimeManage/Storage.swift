//
//  Storage.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/04.
//

public protocol RuntimeLibrary
{
    associatedtype Configuration
    
    /// returns the best matching ``Runtime`` in this ``RuntimeLibrary``.
    /// submit ``RuntimeInspector`` to check wheather items satisfied requirements.
    /// there might be more than one match in the library,
    /// the one has best ``RuntimeHealthIndex``  will be returned.
    func search(requirements:[any RuntimeInspector], config:Configuration) throws -> (Runtime,RuntimeHealthIndex)
    
    /// returns all eligible runtime packages along with their compatibility levels.
    func searchAll(requirements:[any RuntimeInspector], config:Configuration) throws -> any Sequence<(Runtime,RuntimeHealthIndex)>
}

public final class LocalRuntimeLibrary: RuntimeLibrary
{
    private var sreachingFolders:[URL]
    private var analyzedItems:[Runtime] = []
    
    public typealias Configuration = [Configs]
    
    public func search(requirements:[any RuntimeInspector], config:[Configs] = Configs.default) throws -> (Runtime,RuntimeHealthIndex)
    {
        var best:(Runtime,RuntimeHealthIndex)? = nil
        for (runtime,health) in try self.searchAll(requirements:requirements, config:config)
        {
            if best == nil
            {
                best = (runtime,health)
                continue
            }
            if health > best!.1
            {
                best = (runtime,health)
                continue
            }
        }
        return if let best = best { best } else { throw Errors.noMatchesFound }
    }
    
    public func searchAll(requirements:[any RuntimeInspector], config:[Configs] = Configs.default) throws -> any Sequence<(Runtime,RuntimeHealthIndex)>
    {
        // configuration properties
        var refresh = false
        
        // config parsing
        for conf in config
        {
            switch conf
            {
                case .refreshBeforeSreaching(let status): refresh = status
            }
        }
        
        if refresh { _ = try self.refresh() }
        
        // sreaching
        var result:[(Runtime,RuntimeHealthIndex)] = []
        for item in analyzedItems
        {
            var healthIndex = RuntimeHealthIndex(0)
            for inspector in requirements
            {
                healthIndex += inspector.examine(item)
            }
            if !healthIndex.isHealth { continue }
            result.append((item,healthIndex))
        }
        
        return result
    }
    
    public func refresh() throws -> Self
    {
        // for each subitems in sreaching folders
        var sreachingItems:[URL] = []
        for folder in sreachingFolders
        {
            for item in try FileManager.default.contentsOfDirectory(at:folder, includingPropertiesForKeys:nil)
            {
                sreachingItems.append(item)
            }
        }
        // initial processing: find items that may be runtime packages
        var preliminary:[URL] = []
        for item in sreachingItems
        {
            let extensionName = item.pathExtension
            if extensionName != "jdk" && extensionName != "jre" { continue }
            let releaseInfoFile = item.appending(components:"Contents","Home","release")
            if !FileManager.default.fileExists(atPath:releaseInfoFile.path()) { continue }
            preliminary.append(releaseInfoFile)
        }
        
        // further processing: analyze release info to runtimes
        var analyzed:[Runtime] = []
        for infoFile in preliminary
        {
            let releaseInfo = try String(contentsOf:infoFile, encoding: .utf8)
                .split(separator:"\n")
                .map{ String($0) }
            let metadata = try RuntimeMetadata(withReleaseInformation:releaseInfo)
            let home = infoFile.deletingLastPathComponent()
            let executable = home.appending(components:"bin","java")
            if !FileManager.default.fileExists(atPath:home.path()) { continue }
            let package = RuntimePackage.structure(executable:executable, home:home)
            let result = Runtime(metadata:metadata, files:package)
            analyzed.append(result)
        }
        
        self.analyzedItems = analyzed
        return self
    }
    
    init(folders:[URL])
    {
        self.sreachingFolders = folders
    }
    
    public enum Configs
    {
        case refreshBeforeSreaching(status:Bool)
        
        public static var `default`:[Configs] =
        [
            .refreshBeforeSreaching(status:true)
        ]
    }
    
    public enum Errors: Error
    {
        case noMatchesFound
    }
}

extension LocalRuntimeLibrary
{
    public enum Levels
    {
        case system
        case user
    }
    
    convenience init(level:Levels)
    {
        let folders = switch level
        {
            case .system: [URL(fileURLWithPath:"/Library/Java/JavaVirtualMachines/")]
            case .user: [URL.libraryDirectory.appending(components:"Java","JavaVirtualMachines")]
        }
        self.init(folders:folders)
    }
}
