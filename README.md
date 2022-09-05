# sf-permissions-endpoint
Salesforce custom REST API endpoint to retrieve permission information about salesforce user

Request URI

```
POST /perms-api/v1/user-permissions?id=userId
```

Request body

```
{
    "perms": ["PermissionsModifyAllData"],
    "account": ["PermissionsEdit"],
    "opportunity": []
}
```

Response body

```
{
    "perms": {
        "PermissionsModifyAllData": true
    },
    "Account": {
        "PermissionsEdit": true
    },
    "Opportunity": {
        "PermissionsModifyAllRecords": true,
        "PermissionsViewAllRecords": true,
        "PermissionsDelete": true,
        "PermissionsRead": true,
        "PermissionsCreate": true,
        "PermissionsEdit": true
    },
}
```