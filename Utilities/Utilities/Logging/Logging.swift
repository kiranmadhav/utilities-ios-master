//
//  Logging.swift
//  Utilities
//
//  Created by jbrooks on 6/30/16.
//  Copyright © 2016 MHE. All rights reserved.

// Logging utility
//
// Usage:
// Declare a logging object in your app or sdk:
// let myLog = Log(name: "APP LOG")
//
// In the app, call enable() at launch time, e.g.:
// #if VERBOSE
//     myAppLog.enable(withLevel: .verbose)
// #elif DEBUG
//     myAppLog.enable(withLevel: .debug)
// #else
//     myAppLog.enable(withLevel: .info)
// #endif
//
// Subsequently messages can be logged like this:
//   myLog.warning("Some message")
//   myLog.info("Some informational message")
//   myLog.error("Some error")
//
// Log statements have the following form:
//   myLog <log level>: <function name>, <file name>, line <line number>:\n\t Some message

import Foundation
import CleanroomLogger

@objc
public enum LogLevel: Int {
    case verbose
    case debug
    case info
    case warning
    case error
    case none
    
    var prefix: String {
        switch self {
        case .verbose:
            return "VERBOSE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .none:
            return ""
        }
    }
}

@objc
open class Log: NSObject {
    /**
     Configure and enable the logger.  The resulting configured log will be shared by all dependent frameworks.  To be called by the application, once, when the app launches.  Logging fails silently if the logger has not been enabled.
     - Parameter level: log level which is the minimum tha entries must have in order to print.
     - Parameter writeToFile: file path if file output is desired.  The containing directory must exist and be writable by the app.  The file need not exist; it will be created if it doesn't, and appended to if it does.
     */
    public func enable(withLevel level: LogLevel = .info, writeToFile: URL? = nil, synchronous: Bool = false) {
        let minimumSeverity: LogSeverity
        switch level {
        case .info:
            minimumSeverity = LogSeverity.info
        case .warning:
            minimumSeverity = LogSeverity.warning
        case .error:
            minimumSeverity = LogSeverity.error
        case .debug:
            minimumSeverity = LogSeverity.debug
        case .verbose:
            minimumSeverity = LogSeverity.verbose
        case .none:
            return
        }
        let recorder: LogRecorder
        if let filePath = writeToFile {
            // Create a recorder for logging to a file.
            guard let fileRecorder = FileLogRecorder(filePath: filePath.path, formatters: [PayloadLogFormatter()]) else {
                return
            }
            recorder = fileRecorder
        } else {
            // Create a recorder for logging to stdout & stderr.
            recorder = StandardStreamsLogRecorder(formatters: [PayloadLogFormatter()])
        }
        let config = BasicLogConfiguration(minimumSeverity: minimumSeverity, recorders: [recorder], synchronousMode: synchronous)
        CleanroomLogger.Log.enable(configuration: config)
    }
    
    /**
     Initialize logger.
     - Parameter name: name that will prefix the log entry.
     */
    public init(name: String) {
        self.name = name
    }
    
    /**
     Log items at the info level, including the caller information.
     - Parameter caller: name of the function calling this one.
     - Parameter file: name of the function's source file.
     - Parameter line: line number in the file.
     - Parameter items: the items to log
     */
    public func info(caller: String = #function, file: String? = #file, line: Int? = #line, _ items: Any...) {
        printItems(LogLevel.info, caller, file, line, items, channel: CleanroomLogger.Log.info)
    }
    
    /**
     Log items at the warning level, including the caller information.
     - Parameter caller: name of the function calling this one.
     - Parameter file: name of the function's source file.
     - Parameter line: line number in the file.
     - Parameter items: the items to log
     */
    public func warning(caller: String = #function, file: String? = #file, line: Int? = #line, _ items: Any...) {
        printItems(LogLevel.warning, caller, file, line, items, channel: CleanroomLogger.Log.warning)
    }
    
    /**
     Log items at the error level, including the caller information.
     - Parameter caller: name of the function calling this one.
     - Parameter file: name of the function's source file.
     - Parameter line: line number in the file.
     - Parameter items: the items to log
     */
    public func error(caller: String = #function, file: String? = #file, line: Int? = #line, _ items: Any...) {
        printItems(LogLevel.error, caller, file, line, items, channel: CleanroomLogger.Log.error)
    }
    
    /**
     Log items at the debug level, including the caller information.
     - Parameter caller: name of the function calling this one.
     - Parameter file: name of the function's source file.
     - Parameter line: line number in the file.
     - Parameter items: the items to log
     */
    public func debug(caller: String = #function, file: String? = #file, line: Int? = #line, _ items: Any...) {
        printItems(LogLevel.debug, caller, file, line, items, channel: CleanroomLogger.Log.debug)
    }
    
    /**
     Log items at the verbose level, including the caller information.
     - Parameter caller: name of the function calling this one.
     - Parameter file: name of the function's source file.
     - Parameter line: line number in the file.
     - Parameter items: the items to log
     */
    public func verbose(caller: String = #function, file: String? = #file, line: Int? = #line, _ items: Any...) {
        printItems(LogLevel.verbose, caller, file, line, items, channel: CleanroomLogger.Log.verbose)
    }

    private let name: String

    // Note: the stackFrame and callsite format fields are CL's way of accessing the calling function, file, and line number.  But we can't use these because we're hiding the CL messaging under the Logger interface, such that the caller and call site will always be this function. So, we pass along the #function, #file and #line and splice them into the message (since the format has already been set at this point).  Unfortunate.
    //swiftlint:disable:next function_parameter_count
    private func printItems(_ level: LogLevel, _ caller: String, _ file: String?, _ line: Int?, _ items: [Any], channel: LogChannel?) {
        
        let filename = file?.components(separatedBy: "/").last
        
        let prefix = "\(name)" + " " + "\(level.prefix)" + ": " + "\(caller)" +
            (filename != nil ? ", \(filename!)" : "")  +
            (line != nil ? ", line \(line!)" : "") + ":\n\t"
        
        items.forEach { item in
            if let string = item as? String {
                channel?.message(prefix + string)
            } else {
                // Use the debug description for more useful debugging
                channel?.message(prefix + String(reflecting: item))
            }
        }
    }
}

//The following extension provides specially formatted logging for network 
//requests and responses.  They are #defined to be no-ops in non-DEBUG builds.
//The main risk is that a request might contain sensitive information like a 
//user's password
public extension Log {
    func networkQueue(_ item: Any) {
        #if DEBUG
        print(
            "\n-----  QUEUING REQUEST -----\n",
            item,
            "\n----------------------------\n",
            terminator: "\n")
        #endif
    }

    func networkRequest(_ item: Any) {
        #if DEBUG
        print(
            "\n-----  SENDING REQUEST -----\n",
            item,
            "\n----------------------------\n",
            terminator: "\n")
        #endif
    }

    func networkResponse(_ item: Any) {
        #if DEBUG
        print(
            "\n-----  RESPONSE -----\n",
            item,
            "\n---------------------\n",
            terminator: "\n")
        #endif
    }
}
