//
//  Cache.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/02.
//

public class Cache<T>
{
    public private(set) var data: T
    
    public private(set) var lastUpdateTime: Date
    
    public func update(newValue:T)
    {
        self.data = newValue
        self.lastUpdateTime = Date()
    }
    
    init(initalValue data:T)
    {
        self.data = data
        self.lastUpdateTime = Date()
    }
}

public class Timer
{
    private var status: Bool
    private var interval: TimeInterval
    private var task: ()->Void
    
    public func pause() { status = false }
    public func resume() { status = true; run() }
    
    private func run()
    {
        Task
        {
            while status
            {
                task()
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    init(timeInterval interval:TimeInterval, autoStart status:Bool = true, task:@escaping ()->Void)
    {
        self.interval = interval
        self.status = status
        self.task = task
        
        run()
    }
}

extension Cache
{
    public typealias Seconds = TimeInterval
    
    convenience init(initalData inital:T, refreshTimeInterval interval:Seconds, refreshDataSource update:@escaping ()->T)
    {
        self.init(initalValue: inital)
        let _ = Timer(timeInterval: interval, autoStart: true)
        {
            self.update(newValue: update())
        }
    }
    
    convenience init(refreshTimeInterval interval:Seconds, fetchDataFrom update:@escaping ()->T)
    {
        self.init(initalData: update(), refreshTimeInterval: interval, refreshDataSource: update)
    }
}

extension Cache: CustomStringConvertible
{
    public var description: String
    {
        return "Cached(\(data))"
    }
}
