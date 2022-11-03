//
//  EPubServer.swift
//  SimpleEPub
//
//  Created by jbrooks on 12/3/15.
//  Copyright © 2015 MHE. All rights reserved.
//

import UIKit
import GCDWebServer
import PromiseKit

private let log: Log = {
    let log = Log(name: "WEB SERVER LOG")
    log.enable(withLevel: .info)
    return log
}()

//This class emulates the starting and stopping of servers done by GCDWebServer.
//(More info: https://github.com/swisspol/GCDWebServer#gcdwebserver--background-mode-for-ios-apps )
//Here, though, we detect when our port has been stolen and choose a new one, ensuring that the reader
//refreshes itself to incorporate the new urls in its location calculations.
public class ServerPauser: NSObject {
    static public let shared: ServerPauser = {
        let sp = ServerPauser()

        NotificationCenter.default.addObserver(sp, selector: #selector(pauseAll(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(sp, selector: #selector(startAll(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)

        return sp
    }()

    private let hashTable = NSHashTable<WebServer>.weakObjects()

    fileprivate func add(_ server: WebServer) {
        hashTable.add(server)
    }

    fileprivate func remove(_ server: WebServer) {
        hashTable.remove(server)
    }

    private(set) public var afterServersStart: Promise<Void> = .value(())
    private var serverPromiseResolver: Resolver<Void>?

    @objc
    func pauseAll(_: Notification) {
        log.info("Pausing local servers")
        hashTable.allObjects.forEach { $0.pauseServer() }

        let (promise, resolver) = Promise<Void>.pending()

        afterServersStart = promise
        serverPromiseResolver = resolver
    }

    @objc
    func startAll(_: Notification) {
        var anyFailedError: Error?

        log.info("Starting local servers")
        for server in hashTable.allObjects {

            do {
                try server.restartServer()
            } catch {
                if !server.startNewServer() {
                    log.error("Failed to restart directory: \(server)")
                    anyFailedError = error
                }
            }
        }

        if let error = anyFailedError {
            serverPromiseResolver?.reject(error)
        } else {
            serverPromiseResolver?.fulfill(())
        }
    }
}

open class WebServer {
    public let baseFileURL: URL
    public let server = GCDWebServer()

    private var id: String {
        return "\(baseFileURL.hashValue)"
    }

    private var basePath: String {
        return id
    }

    private var port: UInt?

    public init(baseDirectory: URL) {
        baseFileURL = baseDirectory
        configureHandlers()
        startNewServer()
        ServerPauser.shared.add(self)
    }

    deinit {
        pauseServer()
        ServerPauser.shared.remove(self)
        WebServer.resetPort()
    }

    //Cache age for statically-served content (not applicable to our dynamic html/xhtml responses)
    private static let kCacheAge: UInt = 3600

    private static let kMinPort: UInt = 8080
    private static let kMaxPort: UInt = 65535

    //Port to serve - It gets incremented every time a server gets spun up
    private static var currentPort = kMinPort

    static func resetPort() {
        //If the resourceServer is alive, reset to the port just past the resource server
        //(to silence errors on next launch)
        if let port = WebServer.resourcesServer?.server.port {
            currentPort = port + 1
        } else {
            currentPort = kMinPort
        }
    }

    public var baseServerURL: URL? {
        if serverIsRunning {
            return server.serverURL?.withAppendedURLString(basePath)
        }

        log.error("server is not running when baseServerURL requested.  Downstream trouble.")
        return nil
    }

    var serverIsRunning: Bool {
        return server.isRunning && server.serverURL != nil
    }

    //We mirror GCDWebServer practice of saving the options used to start the server
    //If currentOptions are non-nil, the server is either running or paused
    var currentOptions: [String: Any]?

    open func configureHandlers() {
        //3 == WARNING
        GCDWebServer.setLogLevel(3)

        let pathToServe = "/" + basePath + "/"

        //base class serves EVERYTHING in the folder unaltered
        server.addGETHandler(forBasePath: pathToServe, directoryPath: baseFileURL.path, indexFilename: nil, cacheAge: WebServer.kCacheAge,
                             allowRangeRequests: true)
    }

    //Once a server is started, it's started for good until dealloc
    @discardableResult
    open func startNewServer() -> Bool {
        if serverIsRunning { return true }

        while true {
            let port = WebServer.currentPort
            let options: [String: Any] = [
                GCDWebServerOption_BindToLocalhost: true,
                GCDWebServerOption_Port: port,
                GCDWebServerOption_AutomaticallySuspendInBackground: false
                ]

            do {
                try server.start(
                    options: options
                )
                self.port = port
                log.info("Server Started on Port: \(port).")
                currentOptions = options

                //We must increment the port because each GCDWebServer instance must be on its own port
                if WebServer.currentPort >= WebServer.kMaxPort {
                    WebServer.currentPort = WebServer.kMinPort
                } else {
                    WebServer.currentPort += 1
                }
                //Success!
                return true
            } catch POSIXError.EADDRINUSE {
                //There's already a server on this port.  We'll try a new one...

                if WebServer.currentPort >= WebServer.kMaxPort {

                    //Too high.  Give up.  (only wrap-around in the success case above.  Don't want
                    //the possibility of an infinite loop)
                    log.error("Failed to start server.  No more ports available.")
                    return false
                } else {
                    //Increment the port and try again
                    log.info("Port: \(port) in use. Trying next one.")
                    WebServer.currentPort += 1
                    continue
                }

            } catch {

                //fail on all other errors
                log.error("Failed to start server on Port: \(port) with error: \(error)")
                return false
            }
        }
    }

    open func pauseServer() {
        log.info("Pausing server on port: \(port ?? 0)")
        if server.isRunning {
            server.stop()
        }
    }

    //Tries to restart with existing options.
    @discardableResult
    open func restartServer() throws -> Bool {
        guard let options = currentOptions else {
            return false
        }

        try server.start(options: options)

        return true
    }

    static private let resourcesServer: WebServer? = {
        if let resourcesFolder = Bundle.module.resourcePath {

            let resourcesURL = URL(fileURLWithPath: resourcesFolder + "/PackageResources")
            let server = WebServer(baseDirectory: resourcesURL)

            return server
        }

        return nil
    }()

    public static func startResourceServerIfNeeded() {
        _ = resourcesServer
    }

    //The base url from which to get all our common js and css in resources
    public static var resourcesCDN: URL? {
        return resourcesServer?.baseServerURL
    }
}
