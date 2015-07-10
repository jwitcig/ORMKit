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
    public var database: CKDatabase {
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
                self.fetchLiftTemplates(organizations: [organization], completionHandler: completionHandler)
            } else {
                var response = ORCloudDataResponse()
                response.error = ORDataTools.currentOrganizationMissingError
                completionHandler?(response)
            }
        }
    }
    
    public func fetchLiftTemplates(#organizations: [OROrganization], completionHandler: ((ORCloudDataResponse)->())?) {
        let references = organizations.map { $0.reference }
        let predicate = ORDataTools.predicateWithKey("organization", comparator: "IN", value: references)
        
        self.dataManager.fetchCloud(model: ORLiftTemplate.self, predicate: predicate, completionHandler: completionHandler)
    }

    public func fetchLiftEntries(#template: ORLiftTemplate, completionHandler: ((ORCloudDataResponse)->())?) {
        let predicate = ORDataTools.predicateWithKey("liftTemplate", comparator: "==", value: template.reference)
        self.dataManager.fetchCloud(model: ORLiftEntry.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func fetchLiftEntries(#templates: [ORLiftTemplate], completionHandler: ((ORCloudDataResponse)->())?) {
        
        let predicate = ORDataTools.predicateWithKey("liftTemplate", comparator: "IN", value: ORLiftTemplate.references(models: templates))
        self.dataManager.fetchCloud(model: ORLiftEntry.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func fetchMessages(#organization: OROrganization, completionHandler: ((ORCloudDataResponse)->())?) {
        let predicate = ORDataTools.predicateWithKey("organization", comparator: "==", value: organization.reference)
        self.dataManager.fetchCloud(model: ORMessage.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func save(#model: ORModel, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.saveCloud(record: model.record, completionHandler: completionHandler)
    }
    
    public func fetchAthletes(#organization: OROrganization, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORAthlete.self, predicate: ORDataTools.allRows, completionHandler: completionHandler)
    }
    
    public func syncronizeDataToLocalStore(completionHandler: ((ORCloudDataResponse)->())? = nil) {
        self.fetchAssociatedOrganizations(self.session.currentAthlete!) { (response) -> () in
            if response.success {
                
                var organizations = OROrganization.organizations(records: response.cloudResults)
                
                self.session.localData.save()
                
                self.fetchLiftTemplates(organizations: organizations) { (response) -> () in
                    if response.success {
                        
                        var templates = ORLiftTemplate.templates(records: response.results as! [CKRecord])
                        self.session.localData.save()
                        
                        self.fetchLiftEntries(templates: templates) { (response) -> () in
                            if response.success {
                                var entries = ORLiftEntry.entries(records: response.results as! [CKRecord])
                                self.session.localData.save()
                            
                            
                                completionHandler?(response)
                            
                            } else {
                                completionHandler?(response)
                            }
                        }
                        
                    } else  {
                        completionHandler?(response)
                    }
                }
                
            } else {
                completionHandler?(response)
            }
        }
    }
    
}