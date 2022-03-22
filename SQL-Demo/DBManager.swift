//
//  DBManager.swift
//  SQL-Demo
//
//  Created by Neosoft on 22/03/22.
//
import Foundation
import SQLite3
  
  
class DBManager {
    init() {
        db = openDatabase()
        createTable()
    }
  
  
    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?
  
  
    func openDatabase() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(filePath.path, &db) != SQLITE_OK {
            debugPrint("can't open database")
            return nil
        } else {
            print("Successfully created connection to database at \(dbPath)")
            return db
        }
    }
      
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS persons(Id INTEGER PRIMARY KEY,name TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Person table created.")
            } else {
                print("Person table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
      
      
    func insert(id:Int, name:String) {
        let persons = read()
        for p in persons {
            if p.id == id {
                print("ID already exists")
                return
            }
        }
        let insertStatementString = "INSERT INTO persons (Id, name) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(id))
            sqlite3_bind_text(insertStatement, 2, (name as NSString).utf8String, -1, nil)
              
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
      
    func read() -> [Person] {
        let queryStatementString = "SELECT * FROM persons;"
        var queryStatement: OpaquePointer? = nil
        var peoples : [Person] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                peoples.append(Person(id: Int(id), name: name))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return peoples
    }
      
    func deleteByID(id:Int) {
        let deleteStatementStirng = "DELETE FROM persons WHERE Id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
      
}
