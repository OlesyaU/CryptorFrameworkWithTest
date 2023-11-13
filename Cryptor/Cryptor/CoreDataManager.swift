//
//  CoreDataManager.swift
//  Cryptor
//
//  Created by Олеся on 10.11.2023.
//

import Foundation
import CoreData

final class CoreDataManager {
    static var shared = CoreDataManager()
    var encrypteds: [EncryptString] = []
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EncryptString")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private func generateSecureStoreInstance(string: String) -> SecureStore {
        let genericInstance = GenericPasswordQueryable(service: string)
        let secureStoreInstance = SecureStore(secureStoreQueryable: genericInstance)
        return secureStoreInstance
    }

    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addString(string: String) {
        persistentContainer.performBackgroundTask { backgroundContext in
            let objectEncryptString = EncryptString(context: backgroundContext)
            objectEncryptString.string = string
            objectEncryptString.id = UUID(uuidString: string)
            guard let objectID = objectEncryptString.id?.uuidString else {return}
            do {
                try  self.generateSecureStoreInstance(string: string).setValue(string, for: objectID)
                try backgroundContext.save()
            } catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func getValues() -> [String] {
        var strings = [String]()
        let request = EncryptString.fetchRequest()
        let stringsFromDataBase = (try? persistentContainer.viewContext.fetch(request)) ?? []
        encrypteds = stringsFromDataBase
        try? stringsFromDataBase.forEach { encryptString in
            guard let encryptStringValue = encryptString.id?.uuidString
            else {return}
            do {
                guard let encryptStringFromStore = try generateSecureStoreInstance(string: encryptStringValue).getValue(for: encryptStringValue) else {return}
                strings.append(encryptStringFromStore)
            } catch {
                throw SecureStoreError.string2DataConversionError
            }
        }
        return strings
    }
    
    func deleteEncryptString(string: String) {
        guard let encryptString = encrypteds.first(where: {$0.id == UUID(uuidString: string) }) else {return}
        guard let objectID = encryptString.id?.uuidString else {return}
        persistentContainer.viewContext.delete(encryptString)
        do {
            try  generateSecureStoreInstance(string: string).removeValue(for: objectID)
            saveContext()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EncryptString")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentContainer.viewContext.execute(batchDeleteRequest)
        } catch {
        }
        saveContext()
    }
}
