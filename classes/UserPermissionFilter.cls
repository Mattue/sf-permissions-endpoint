/**
 * Created by Nikita.Mikhailov on 26.08.2022.
 */

public with sharing class UserPermissionFilter {

    public List<Object> perms { get; set; }
    public Map<String, List<Object>> sObjectsPerms { get; set; }

    /*******************************************************************************
    *  Name            : build
    *  Summary         : build UserPermissionFilter by provided filtering values
    *  Parameters      : requestedPerms - map where keys are names of sObjects (or root permissions)
     *  and values is list of requested permissions.
    *  @return         : UserPermissionFilter
    ******************************************************************************/
    public static UserPermissionFilter build(Map<String, Object> requestedPerms) {

        UserPermissionFilter permsFilter = new UserPermissionFilter();

        for (String key : requestedPerms.keySet()) {
            if (key.equals('perms')) {
                permsFilter.perms = (List<Object>) requestedPerms.get(key);
            } else {

                if (permsFilter.sObjectsPerms == null) {
                    permsFilter.sObjectsPerms = new Map<String, List<Object>>();
                }

                permsFilter.sObjectsPerms.put(key, (List<Object>) requestedPerms.get(key));
            }
        }

        return permsFilter;
    }
}