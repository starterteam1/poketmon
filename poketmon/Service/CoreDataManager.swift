import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PoketmonContact")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createContact(name: String, phoneNumber: String, imageUrl: String) {
        let contact = Contact(context: context)
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.imageUrl = imageUrl
        saveContext()
    }
    
    func fetchContacts(sortedBy sortDescriptor: NSSortDescriptor) -> [Contact] {
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching contacts: \(error)")
            return []
        }
    }
    
    func updateContact(contact: Contact, name: String, phoneNumber: String, imageUrl: String) {
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.imageUrl = imageUrl
        saveContext()
    }
    
    func deleteContact(contact: Contact) {
        context.delete(contact)
        saveContext()
    }
}
