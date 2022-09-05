/**
 * Created by Nikita.Mikhailov on 24.08.2022.
 */

public with sharing class UserPermissionsService {

    /*******************************************************************************
    *  Name            : buildPermissionData
    *  Summary         : Builds permission data of user using permission request.
    *  Parameters      : userId, permissionRequest map representation of filtering JSON
    *  @return         : map of objects with requested permissions per object
    ******************************************************************************/
    public static Map<String, Object> buildPermissionData(Id userId, Map<String, Object> permissionRequest) {

        UserPermissionFilter userPermissionFilter = UserPermissionFilter.build(permissionRequest);

        Map<String, Object> resMap = new Map<String, Object>();

        Set<Id> permSetsIds = UserPermissionsDAO.queryAssignedPermSets(userId);

        Map<String, Object> profilePermission = getAssignedPermissionsData(permSetsIds, userPermissionFilter.perms);

        if (profilePermission != null) {
            resMap.put('perms', profilePermission);
        }

        Map<String, Object> sObjectPermissions = getObjectsAccessData(permSetsIds, userPermissionFilter.sObjectsPerms);

        if (sObjectPermissions != null) {
            resMap.putAll(sObjectPermissions);
        }

        return resMap;
    }

    private static Map<String, Object> getAssignedPermissionsData(Set<Id> permSetsIds, List<Object> filter) {

        if (filter == null) {
            return null;
        }

        List<PermissionSet> userPermSets;

        try {
            userPermSets = UserPermissionsDAO.queryPermissionsSets(permSetsIds, filter);
        } catch (Exception e) {
            return new Map<String, Object>{
                    'error' => e.getMessage()
            };
        }

        Map<String, Object> profileData = new Map<String, Object>();

        for (PermissionSet permSet : userPermSets) {
            for (String permName : permSet.getPopulatedFieldsAsMap().keySet()) {
                if (filter.isEmpty() || filter.contains(permName)) {
                    if (!profileData.containsKey(permName) || !((Boolean) profileData.get(permName))) {
                        profileData.put(permName, permSet.get(permName));
                    }
                }
            }
        }

        System.debug(JSON.serialize(profileData));

        return profileData;
    }

    //TODO: include toLowerCase to avoid issues with Strings
    private static Map<String, Object> getObjectsAccessData(Set<Id> permSetsIds, Map<String, List<Object>> fieldsFilter) {

        if (fieldsFilter == null) {
            return null;
        }

        List<ObjectPermissions> objectPermsList;

        try {
            objectPermsList = UserPermissionsDAO.queryObjectPermissions(permSetsIds, fieldsFilter);
        } catch (Exception e) {
            return new Map<String, Object>{
                    'error' => e.getMessage()
            };
        }

        Map<String, Map<String, Object>> objAccessData = new Map<String, Map<String, Object>>();

        for (ObjectPermissions objectPerms : objectPermsList) {
            if (objAccessData.containsKey(objectPerms.SobjectType)) {
                //this sobject type exists in this map
                //need to run through all false fields and change to true if needed
                for (String field : objAccessData.get(objectPerms.SobjectType).keySet()) {
                    //change value only if it changes from false to true
                    if ((Boolean) objectPerms.get(field) || (Boolean) objAccessData.get(objectPerms.SobjectType).get(field)) {
                        objAccessData.get(objectPerms.SobjectType).put(field, objectPerms.get(field));
                    }
                }
            } else {
                //TODO: fix case to avoid string issues
                objAccessData.put(objectPerms.SobjectType, getRequestedFields(objectPerms.getPopulatedFieldsAsMap(), fieldsFilter.get(objectPerms.SobjectType.toLowerCase())));
            }
        }

        System.debug(JSON.serialize(objAccessData));

        return objAccessData;
    }

    private static Map<String, Object> getRequestedFields(Map<String, Object> populatedFields, List<Object> filteringFields) {
        Map<String, Object> requestedFields = new Map<String, Object>();

        for (Object fieldName : filteringFields) {
            requestedFields.put((String) fieldName, populatedFields.get((String) fieldName));
        }

        return requestedFields;
    }
}