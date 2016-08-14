//
//  SRSDistributionCoder.swift
//  WaniKaniKit
//
//  Copyright © 2015 Chris Laverty. All rights reserved.
//

import Foundation
import CocoaLumberjack
import FMDB
import SwiftyJSON

public extension SRSDistribution {
    static let coder = SRSDistributionCoder()
}

public final class SRSDistributionCoder: SRSItemCountsItem, ResourceHandler, JSONDecoder, SingleItemDatabaseCoder {
    private struct Columns {
        static let apprentice = "apprentice"
        static let guru = "guru"
        static let master = "master"
        static let enlightened = "enlighten"
        static let burned = "burned"
        static let srsLevel = "srs_level"
        static let lastUpdateTimestamp = "last_update_timestamp"
    }
    
    // MARK: - ResourceHandler
    
    public var resource: Resource { return .srsDistribution }
    
    // MARK: - JSONDecoder
    
    public func load(from json: JSON) -> SRSDistribution? {
        guard let dictionary = json.dictionary else {
            return nil
        }
        
        var countsBySRSLevel = [SRSLevel: SRSItemCounts]()
        for (key, value) in dictionary {
            if let srsLevel = SRSLevel(rawValue: key), let itemCounts = SRSItemCounts.coder.load(from: value) {
                countsBySRSLevel[srsLevel] = itemCounts
            }
        }
        
        return SRSDistribution(countsBySRSLevel: countsBySRSLevel)
    }
    
    // MARK: - DatabaseCoder
    
    static let tableName = "srs_distribution"
    
    override var columnDefinitions: String {
        return "\(Columns.srsLevel) TEXT PRIMARY KEY, " +
            "\(Columns.lastUpdateTimestamp) INT NOT NULL, " +
            super.columnDefinitions
    }
    
    override var columnNameList: [String] {
        return [Columns.srsLevel, Columns.lastUpdateTimestamp] + super.columnNameList
    }
    
    public func createTable(in database: FMDatabase, dropExisting: Bool) throws {
        if dropExisting {
            try database.executeUpdate("DROP TABLE IF EXISTS \(self.dynamicType.tableName)")
        }
        
        try database.executeUpdate("CREATE TABLE IF NOT EXISTS \(self.dynamicType.tableName)(\(columnDefinitions))")
    }
    
    public func load(from database: FMDatabase) throws -> SRSDistribution? {
        let resultSet = try database.executeQuery("SELECT \(columnNames) FROM \(self.dynamicType.tableName)")
        defer { resultSet.close() }
        
        var countsBySRSLevel = [SRSLevel: SRSItemCounts]()
        var lastUpdateTimestamp: Date?
        
        while resultSet.next() {
            guard let srsLevelRawValue = resultSet.string(forColumn: Columns.srsLevel) else {
                DDLogWarn("When creating SRSDistribution, missing column '\(Columns.srsLevel)'")
                continue
            }
            guard let srsLevel = SRSLevel(rawValue: srsLevelRawValue) else {
                DDLogWarn("When creating SRSDistribution, ignoring unrecognised SRS level '\(srsLevelRawValue)'")
                continue
            }
            let srsItemCounts = try loadSRSItemCountsForRow(resultSet)
            countsBySRSLevel[srsLevel] = srsItemCounts
            lastUpdateTimestamp = resultSet.date(forColumn: Columns.lastUpdateTimestamp).laterDateIfNotNil(lastUpdateTimestamp)
        }
        
        return SRSDistribution(countsBySRSLevel: countsBySRSLevel, lastUpdateTimestamp: lastUpdateTimestamp)
    }
    
    private lazy var updateSQL: String = {
        let columnValuePlaceholders = self.createColumnValuePlaceholders(self.columnCount)
        return "INSERT INTO \(self.dynamicType.tableName)(\(self.columnNames)) VALUES (\(columnValuePlaceholders))"
    }()
    
    public func save(_ model: SRSDistribution, to database: FMDatabase) throws {
        try database.executeUpdate("DELETE FROM \(self.dynamicType.tableName)")
        
        for (srsLevel, srsItemCounts) in model.countsBySRSLevel {
            let columnValues: [AnyObject] = [srsLevel.rawValue, model.lastUpdateTimestamp] + srsItemCountsColumnValues(srsItemCounts)
            
            try database.executeUpdate(updateSQL, values: columnValues)
        }
    }
    
    public func hasBeenUpdated(since: Date, in database: FMDatabase) throws -> Bool {
        guard let earliestDate = try database.dateForQuery("SELECT MIN(\(Columns.lastUpdateTimestamp)) FROM \(self.dynamicType.tableName)") else {
            return false
        }
        
        return earliestDate >= since
    }
}

private extension Date {
    func laterDateIfNotNil(_ anotherDate: Date?) -> Date {
        guard let anotherDate = anotherDate else {
            return self
        }
        return max(self, anotherDate)
    }
}
