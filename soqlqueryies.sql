--------------------------------------------------------------------
-- Queries related to distribution of metadata.
-- Find the number of users per profile.
SELECT count(id), Profile.name
FROM User
WHERE User.IsActive = true
GROUP BY Profile.name

-- Find the distribution of Apex classes per namespace.
select count(id), NameSpacePrefix 
from ApexClass 
group by NameSpacePrefix


-- Find the distribution of triggers per object
SELECT TableEnumOrId, Count(Id) num
FROM ApexTrigger
where Status = 'Active' and IsValid = true
GROUP BY TableEnumOrId

-- Find the count of active triggers
select count() from ApexTrigger where Status = 'Active' and IsValid = true

-- Find the details of all triggers (excluding trigger body)
SELECT Name, TableEnumOrId, NamespacePrefix, ApiVersion, 
  Status, IsValid, LengthWithoutComments, 
  UsageAfterDelete, UsageAfterInsert, UsageAfterUndelete, UsageAfterUpdate, UsageBeforeDelete, UsageBeforeInsert, UsageBeforeUpdate
FROM ApexTrigger

-- Find the distribution of Visualforce pages per namespace.
-- Note: Use the Tooling API with this query.
select count(Id), NamespacePrefix 
from ApexPage 
group by NamespacePrefix


-- Identify Flows. Cannot use the Group By clause on the FlowDefinition object.
-- Note: Use the Tooling API with this query.
select Id, ActiveVersion.MasterLabel, ActiveVersion.VersionNumber, NamespacePrefix 
from FlowDefinition
--------------------------------------------------------------------
-- Queries related to distribution of object relationships 
-- and customization.

-- Find Record Types on an object.
select Name, Description 
from RecordType 
where IsActive = true and sObjectType = 'Opportunity'

-- Find all custom fields on an object.
select QualifiedApiName, DataType, DeveloperName, RelationshipName 
from FieldDefinition 
where EntityDefinition.DeveloperName='Opportunity' and 
  RelationshipName = '' and QualifiedApiName like '%__c'
order by DataType 

-- Find all custom relationships on an Object.
select QualifiedApiName, DataType, DeveloperName, RelationshipName 
from FieldDefinition 
where EntityDefinition.DeveloperName='Opportunity' and 
  RelationshipName <> '' and QualifiedApiName like '%__c'
order by DataType 

-- Find all standard relationships on an object.
select QualifiedApiName, DataType, DeveloperName, RelationshipName 
from FieldDefinition 
where EntityDefinition.DeveloperName='Opportunity' and 
  RelationshipName <> '' and (not QualifiedApiName like '%__c') 
order by DataType

-- Find inbound standard relationships to an object. (Rather objects that depend on the specified object.)
select QualifiedApiName, DataType, DeveloperName, RelationshipName, EntityDefinition.DeveloperName 
from FieldDefinition 
where EntityDefinition.DeveloperName <> '' and
  RelationshipName <> '' and 
  DataType = 'Lookup(Opportunity)' and
  (not QualifiedApiName like '%__c') 
order by DataType

-- Find inbound custom relationships to an object. (Rather objects that depend on the specified object.)
select QualifiedApiName, DataType, DeveloperName, RelationshipName, EntityDefinition.DeveloperName 
from FieldDefinition 
where EntityDefinition.DeveloperName <> '' and
  RelationshipName <> '' and 
  DataType = 'Lookup(Opportunity)' and
  QualifiedApiName like '%__c'
order by DataType

--------------------------------------------------------------------
-- Working with Groups
-- Find the number of groups by type
select count(id), Type
from Group
Group By Type

-- Find all Lead queues.
select DeveloperName, Name
from Group
where Type='Queue' and ID IN ( select QueueId from QueueSobject where SobjectType='Lead' )
order by Name
--------------------------------------------------------------------
-- Working with Code

-- Find all Installed Managed Packages
SELECT Id,
    SubscriberPackage.NamespacePrefix,
    SubscriberPackage.Name, 
    SubscriberPackage.Description,
    SubscriberPackageVersion.Name, SubscriberPackageVersion.MajorVersion,SubscriberPackageVersion.MinorVersion,
    SubscriberPackageId, 
    SubscriberPackageVersion.Id,
    SubscriberPackageVersion.PatchVersion,
    SubscriberPackageVersion.BuildNumber
 FROM InstalledSubscriberPackage
 ORDER BY SubscriberPackage.NamespacePrefix

--------------------------------------------------------------------
-- Working with Roles
--Find SF Users Roles (rather than external users)
select ID, Name, ParentRoleId 
from UserRole
where PortalType='None'
--------------------------------------------------------------------
-- Working with Distributions

--Find number of accounts per record type.
select count(id), RecordType.Name
from Account
group by RecordType.Name
--------------------------------------------------------------------
-- Working with List View
-- You can work with a custom object's list views without creating a tab for the object if you know the object's key prefix.
-- Find an object's key prefix.
System.debug('keyPrefix: ' + My_Object__c.SObjectType.getDescribe().getKeyPrefix());
             
-- Work with the object's List Views.
https://[salesforce domain]/[keyPrefix]
             
-- Once a list view is created it can be shared with groups and hosted using the List View component.            
--------------------------------------------------------------------
-- Working with Reports
-- Find the details about all reports in a known folder.
-- This is useful for finding the Developer names for a package.xml manifest.
select Name , DeveloperName, NamespacePrefix, FolderName, Description, Format, LastReferencedDate, LastRunDate, LastViewedDate, OwnerId
from report
where FolderName = 'Evergreen Reports'
             
-- Given a report ID, find its folder.
-- First find the OwnerId of the report.
select Id, DeveloperName, Name, OwnerId FROM Report WHERE Id = '00Oj0000000JjoZEAS'
-- Then using the OwnerId, find the containing Folder. Have not found a way to use a nested query to do this.
select Id, DeveloperName, Name from Folder where Id = '00lj0000000MDqCAAW'
--------------------------------------------------------------------
-- Working with Attachements (Classic)
-- Find distribution of Attachment content types
select ContentType, count(id) 
from attachment
group by ContentType  
           
-- Find distribution of Attachments to Objects
select Parent.Type, count(id) 
from attachment
group by Parent.Type
             
-- Find distribution of public vs private attachements
select IsPrivate, count(id) 
from attachment
group by IsPrivate
-- Note: The above returns empty string for Task. However you can find the number of attachments associated with Tasks withe the below query.
select count(id) 
from attachment
where Parent.Type = 'Task'             
         
             
             
