/**
 * Created by Nikita.Mikhailov on 03.09.2022.
 */

public with sharing class UserPermissionsDAO {

    /*******************************************************************************
    *  Name            : queryPermissionsSets
    *  Summary         : build dynamic SOQL and query PermissionSet using provided
     *  filter and permission set Ids
    *  Parameters      : permSetsIds, filter - expected list of fields of PermissionSet sObject
    *  @return         : List<PermissionSet> or null if no data found
    ******************************************************************************/
    public static List<PermissionSet> queryPermissionsSets(Set<Id> permSetsIds, List<Object> filter) {
        String soqlPermSetsString = 'SELECT ';

        if (filter.isEmpty()) {
            soqlPermSetsString += String.join((Iterable<String>) getBooleanFields('PermissionSet'), ',');
        } else {
            soqlPermSetsString += String.join(filter, ',');
        }

        soqlPermSetsString += ' FROM PermissionSet' +
                ' WHERE Id IN (\'' + String.join((Iterable<Id>) permSetsIds, '\',\'') + '\')' +
                ' LIMIT 10000';

        System.debug(soqlPermSetsString);//TODO: remove nested System.debug before release

        return Database.query(soqlPermSetsString);
    }

    /*******************************************************************************
    *  Name            : queryObjectPermissions
    *  Summary         : build dynamic SOQL and query ObjectPermissions using provided
     *  filter and permission set Ids
    *  Parameters      : permSetsIds, fieldsFilter - map of sObject names
     *  and requested field names of ObjectPermissions sObject
    *  @return         :
    ******************************************************************************/
    public static List<ObjectPermissions> queryObjectPermissions(Set<Id> permSetsIds, Map<String, List<Object>> fieldsFilter) {
        String soqlObjectPerms = 'SELECT SobjectType, ';

        Set<String> queryFields = new Set<String>();

        for (String objName : fieldsFilter.keySet()) {
            if (fieldsFilter.get(objName).isEmpty()) {
                //populate boolean fields for this sObject
                queryFields.addAll(getBooleanFields('ObjectPermissions'));
                fieldsFilter.put(objName, new List<String>(queryFields));

                break; //break cycle because all fields already populated by getBooleanFields
            } else {
                for (Object fieldName : fieldsFilter.get(objName)) {
                    queryFields.add((String) fieldName);
                }
            }
        }

        soqlObjectPerms += String.join((Iterable<String>) queryFields, ',') +
                ' FROM ObjectPermissions' +
                ' WHERE SobjectType IN (\'' + String.join((Iterable<String>) fieldsFilter.keySet(), '\',\'') + '\')' +
                ' AND ParentId IN (\'' + String.join((Iterable<String>) permSetsIds, '\',\'') + '\')' +
                ' LIMIT 10000';

        System.debug(soqlObjectPerms);

        return Database.query(soqlObjectPerms);
    }

    /*******************************************************************************
    *  Name            : queryAssignedPermSets
    *  Summary         : statically query list of assigned permission sets on user
    *  Parameters      : userId
    *  @return         : active and assigned to user set of permission set ids
    ******************************************************************************/
    public static Set<Id> queryAssignedPermSets(Id userId) {

        List<PermissionSetAssignment> permSetAssignments = [
                SELECT PermissionSetId
                FROM PermissionSetAssignment
                WHERE IsActive = TRUE
                AND AssigneeId = :userId
                LIMIT 1000
        ];

        Set<Id> assignedPermSets = new Set<Id>();

        for (PermissionSetAssignment permSetAssignment : permSetAssignments) {
            assignedPermSets.add(permSetAssignment.PermissionSetId);
        }

        return assignedPermSets;
    }

    private static Set<String> getBooleanFields(String sObjectName) {

        Map<String, Schema.SObjectField> sObjFields = Schema.describeSObjects(new List<String>{
                sObjectName
        }).get(0).fields.getMap();

        Set<String> boolFields = new Set<String>();

        for (Schema.SObjectField field : sObjFields.values()) {
            if (field.getDescribe().type == DisplayType.BOOLEAN) {
                boolFields.add(field.getDescribe().name);
            }
        }

        return boolFields;
    }
}