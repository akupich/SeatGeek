//
//  TaskItem.swift
//  SeatGeek
//
//  Created by Andriy Kupich on 5/6/19.
//  Copyright © 2019 Andriy Kupich. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import RxDataSources
import RxSwift

protocol Convertible {
    init?(object: JSONObject)
}

class EventItem: Object, Convertible {
    @objc dynamic var eventId: Int = 0
    @objc dynamic var imageUrlStr: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var date: Date?
    @objc dynamic var isLiked: Bool = false
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(object: JSONObject) {
        self.init()
        
        guard let eventId = object["id"] as? Int else {
                return nil
        }
        self.eventId = eventId
        self.imageUrlStr = (object["performers"] as? [JSONObject])?.first?["image"] as? String ?? ""
        self.title = object["title"] as? String ?? ""
        self.location = (object["venue"] as? JSONObject)?["display_location"] as? String ?? ""
        if let dateStr = object["datetime_local"] as? String {
            self.date = dateStr.toDate(withFormat: "yyyy-MM-dd'T'HH:mm:ss)")
        }
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
}

extension EventItem: IdentifiableType {
    var identity: Int {
        return self.isInvalidated ? 0 : eventId
    }
}

extension EventItem {
    func changeLikeStatus(to isLiked: Bool, in storage: EventsStorageType) {
        self.isLiked = isLiked
        if isLiked {
            storage.create(event: self)
        } else {
            storage.delete(event: self)
        }
        
        #if DEBUG
            storage.logCountOfStoredEvents()
        #endif
    }
    
    func setupLikeStatus(_ storage: EventsStorageType) -> EventItem {
        self.isLiked = storage.find(event: self) != nil
        return self
    }
}
