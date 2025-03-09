//
//  FileChangeObserver.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/05.
//

open class FileChangeObserver
{
    /// a file descriptor for the monitored directory.
    private var monitoredFolderFileDescriptor: CInt = -1
    
    /// a dispatch queue used for sending file changes in the directory.
    private let folderMonitorQueue = DispatchQueue(label: "FolderMonitorQueue", attributes: .concurrent)
    
    /// a dispatch source to monitor a file descriptor created from the directory.
    private var folderMonitorSource: DispatchSourceFileSystemObject?
    
    /// url for the directory being monitored.
    public let monitoredTargetURL: URL
    
    /// custom action to run for monitored changes
    public var action: () -> Void
    
    public init(watchingFile:URL, autoStart:Bool = true, action:@escaping ()->Void)
    {
        self.monitoredTargetURL = watchingFile
        self.action = action
        
        if autoStart { self.resume() }
    }
    
    /// resume for changes to the directory (if we are not already).
    public func resume()
    {
        guard folderMonitorSource == nil && monitoredFolderFileDescriptor == -1 else
        {
            return
        }
        monitoredFolderFileDescriptor = open(monitoredTargetURL.path, O_EVTONLY)
        // Define a dispatch source monitoring the directory for additions, deletions, and renamings.
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredFolderFileDescriptor, eventMask: .write, queue: folderMonitorQueue)
        // Define the block to call when a file change is detected.
        folderMonitorSource?.setEventHandler
        { [weak self] in
            self?.action()
        }
        // Define a cancel handler to ensure the directory is closed when the source is cancelled.
        folderMonitorSource?.setCancelHandler
        { [weak self] in
            guard let strongSelf = self else { return }
            close(strongSelf.monitoredFolderFileDescriptor)
            strongSelf.monitoredFolderFileDescriptor = -1
            strongSelf.folderMonitorSource = nil
        }
        // Start monitoring the directory via the source.
        folderMonitorSource?.resume()
    }
    
    /// cancel listening for changes to the directory, if the source has been created.
    public func cancel()
    {
        folderMonitorSource?.cancel()
    }
}
