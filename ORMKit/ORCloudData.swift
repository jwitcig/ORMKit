//
//  ORCloudData.swift
//  ORMKit
//
//  Created by Developer on 6/18/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORCloudData: DataConvenience {
    
    var dataManager: ORDataManager
    
    var session: ORSession
    
    var container: CKContainer {
        get { return self.dataManager.cloudDataCoordinator.container }
    }
    var database: CKDatabase {
        get { return self.dataManager.cloudDataCoordinator.database }
    }
    
    public required init(session: ORSession, dataManager: ORDataManager) {
        self.session = session
        self.dataManager = dataManager
    }
    
    public func fetchAllOrganizations(completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: OROrganization.self, predicate: ORDataTools.allRows) { (response) in
            completionHandler?(response)
        }
    }
    
    public func fetchAssociatedOrganizations(athlete: ORAthlete, completionHandler: ((ORCloudDataResponse)->())?) {
        let predicate = ORDataTools.predicateWithKey("athletes", comparator: "CONTAINS", value: athlete.reference)
        
        self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) { (response) in
            
            var compoundResults = response.results as! [CKRecord]
            
            let predicate = ORDataTools.predicateWithKey("admins", comparator: "CONTAINS", value: athlete.reference)
            self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) { (response) -> () in
                var recordNames: [String] = compoundResults.map { $0.recordID.recordName }
                compoundResults += (response.results as! [CKRecord]).filter {
                    !contains(recordNames, $0.recordID.recordName)
                }
                
                response.results = compoundResults
                completionHandler?(response)
            }
        }
    }
    
    public func fetchLiftTemplates(#session: ORSession, completionHandler: ((ORCloudDataResponse)->())?) {
        
        if session.soloSession {
            
        } else {
            if let organization = session.currentOrganization {
                let predicate = ORDataTools.predicateWithKey("owner", comparator: "==", value: organization.reference)
                
                self.dataManager.fetchCloud(model: ORLiftTemplate.self, predicate: predicate) { (response) in
                    
                    completionHandler?(response)
                }
            } else {
                var response = ORCloudDataResponse()
                response.error = NSError(domain: "com.jwitapps.ORMKit", code: 500, userInfo: [NSLocalizedDescriptionKey: "No organization object provided to query against."])
                completionHandler?(response)
            }
        }
    }
    
    public func fetchLiftEntries(#template: ORLiftTemplate, completionHandler: ((ORCloudDataResponse)->())?) {
        let predicate = ORDataTools.predicateWithKey("liftTemplate", comparator: "==", value: template.reference)
        self.dataManager.fetchCloud(model: ORLiftEntry.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func save(#model: ORModel, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.saveCloud(record: model.record, completionHandler: completionHandler)
    }
    
}