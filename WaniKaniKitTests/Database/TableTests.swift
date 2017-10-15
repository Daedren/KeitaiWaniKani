//
//  TableTests.swift
//  WaniKaniKitTests
//
//  Copyright © 2017 Chris Laverty. All rights reserved.
//

import XCTest
@testable import WaniKaniKit

private class TestTableCompositePrimaryKey: Table {
    let intColumn = Column(name: "int_column", type: .int, nullable: false, primaryKey: true)
    let intColumnNullable = Column(name: "int_column_nullable", type: .int, nullable: true)
    let floatColumn = Column(name: "float_column", type: .float, nullable: false, unique: true)
    let floatColumnNullable = Column(name: "float_column_nullable", type: .float, nullable: true)
    let numericColumn = Column(name: "numeric_column", type: .numeric, nullable: false, primaryKey: true)
    let numericColumnNullable = Column(name: "numeric_column_nullable", type: .numeric, nullable: true)
    
    init() {
        super.init(name: "test")
    }
}

private class TestTableNoPrimaryKey: Table {
    let intColumn = Column(name: "int_column", type: .int, nullable: false)
    let floatColumn = Column(name: "float_column", type: .float, nullable: false)
    let numericColumn = Column(name: "numeric_column", type: .numeric, nullable: false)
    
    init() {
        super.init(name: "test")
    }
}

private class TestTablePrimaryKey: Table {
    let intColumn = Column(name: "int_column", type: .int, nullable: false, primaryKey: true)
    let textColumn = Column(name: "text_column", type: .text)
    let blobColumn = Column(name: "blob_column", type: .blob)
    
    init() {
        super.init(name: "test")
    }
}

private class TestTableSingleIndex: Table {
    let intColumn = Column(name: "int_column", type: .int, nullable: false)
    let floatColumnNullable = Column(name: "float_column_nullable", type: .float, nullable: true)
    let numericColumnNullable = Column(name: "numeric_column_nullable", type: .numeric, nullable: true)
    
    init() {
        super.init(name: "test",
                   indexes: [TableIndex(name: "idx_test_i1", columns: [floatColumnNullable])])
    }
}

private class TestTableMultipleIndexes: Table {
    let intColumn = Column(name: "int_column", type: .int, nullable: false)
    let floatColumnNullable = Column(name: "float_column_nullable", type: .float, nullable: true)
    let numericColumnNullable = Column(name: "numeric_column_nullable", type: .numeric, nullable: true)
    
    init() {
        super.init(name: "test",
                   indexes: [TableIndex(name: "idx_test_i1", columns: [floatColumnNullable]),
                             TableIndex(name: "idx_test_i2", columns: [intColumn, floatColumnNullable], unique: true)])
    }
}

private class TestVirtualTableNoPrimaryKey: Table {
    let intColumn = Column(name: "int_column", type: .int, nullable: false)
    let floatColumn = Column(name: "float_column", type: .float, nullable: false)
    let numericColumn = Column(name: "numeric_column", type: .numeric, nullable: false)
    
    init() {
        super.init(name: "test", isVirtual: true)
    }
}

class TableTests: XCTestCase {
    
    func testCreateTableStatementNoPrimaryKey() {
        let expectedCreateStmt = "CREATE TABLE test (int_column INTEGER NOT NULL, float_column REAL NOT NULL, numeric_column NUMERIC NOT NULL);"
        let createStmt = TestTableNoPrimaryKey().createTableStatement()
        
        XCTAssertEqual(createStmt, expectedCreateStmt)
    }
    
    func testCreateTableStatementPrimaryKey() {
        let expectedCreateStmt = "CREATE TABLE test (int_column INTEGER NOT NULL PRIMARY KEY, text_column TEXT, blob_column BLOB);"
        let createStmt = TestTablePrimaryKey().createTableStatement()
        
        XCTAssertEqual(createStmt, expectedCreateStmt)
    }
    
    func testCreateTableStatementCompositePrimaryKey() {
        let expectedCreateStmt = "CREATE TABLE test (int_column INTEGER NOT NULL, int_column_nullable INTEGER, float_column REAL NOT NULL UNIQUE, float_column_nullable REAL, numeric_column NUMERIC NOT NULL, numeric_column_nullable NUMERIC, PRIMARY KEY (int_column, numeric_column));"
        let createStmt = TestTableCompositePrimaryKey().createTableStatement()
        
        XCTAssertEqual(createStmt, expectedCreateStmt)
    }
    
    func testCreateTableStatementSingleIndex() {
        let expectedCreateStmt = """
            CREATE TABLE test (int_column INTEGER NOT NULL, float_column_nullable REAL, numeric_column_nullable NUMERIC);
            CREATE INDEX idx_test_i1 ON test (float_column_nullable);
            """
        let createStmt = TestTableSingleIndex().createTableStatement()
        
        XCTAssertEqual(createStmt, expectedCreateStmt)
    }
    
    func testCreateTableStatementMultipleIndexes() {
        let expectedCreateStmt = """
            CREATE TABLE test (int_column INTEGER NOT NULL, float_column_nullable REAL, numeric_column_nullable NUMERIC);
            CREATE INDEX idx_test_i1 ON test (float_column_nullable);
            CREATE UNIQUE INDEX idx_test_i2 ON test (int_column, float_column_nullable);
            """
        let createStmt = TestTableMultipleIndexes().createTableStatement()
        
        XCTAssertEqual(createStmt, expectedCreateStmt)
    }
    
    func testCreateVirtualTableStatementNoPrimaryKey() {
        let expectedCreateStmt = "CREATE VIRTUAL TABLE test USING fts4(tokenize=porter, int_column INTEGER NOT NULL, float_column REAL NOT NULL, numeric_column NUMERIC NOT NULL);"
        let createStmt = TestVirtualTableNoPrimaryKey().createTableStatement()
        
        XCTAssertEqual(createStmt, expectedCreateStmt)
    }
    
}
