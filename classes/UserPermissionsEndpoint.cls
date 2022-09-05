/**
 * Created by Nikita.Mikhailov on 24.08.2022.
 */

/*******************************************************************************
*  Name            : UserPermissionsEndpoint
*  Summary         : REST endpoint to get users permissions (not RESTFull)
******************************************************************************/
@RestResource(UrlMapping='/perms-api/v1/user-permissions')
global with sharing class UserPermissionsEndpoint {

    /*******************************************************************************
    *  Name            : doPost
    *  Summary         : Not a RESTFull resource. Will use body as filter to retrieve
     *  user permissions
    *  200             : Data found, no critical exceptions
    *  400             : Request body is not valid (empty or not valid JSON)
    *  500             : Critical exception - see response body
    ******************************************************************************/
    @HttpPost
    global static void doPost() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        res.addHeader('Content-Type', 'application/json');

        Id userId;

        try {
            userId = req.params.get('id');
        } catch (Exception e) {
            res.statusCode = HttpUtils.HTTP_BAD_REQUEST;
            res.responseBody = Blob.valueOf(ErrorResponse.build(res.statusCode, e.getMessage()));

            return ;
        }

        //validate that user id is provided
        if (userId == null) {
            res.statusCode = HttpUtils.HTTP_BAD_REQUEST;
            res.responseBody = Blob.valueOf(ErrorResponse.build(res.statusCode, 'id URI param is mandatory'));

            return ;
        }

        //validate that body is provided
        //TODO: do we need this?
        if (req.requestBody == null || String.isBlank(req.requestBody.toString())) {
            //TODO: return BAD_REQUEST, because body is mandatory

            res.statusCode = HttpUtils.HTTP_BAD_REQUEST;

            res.responseBody = Blob.valueOf(ErrorResponse.build(res.statusCode, 'Body is empty'));

            return ;
        }

        Map<String, Object> resMap;

        //TODO: investigate possibilities of 500 errors.
//        try {
        resMap = UserPermissionsService.buildPermissionData(userId, (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString()));
//        } catch (Exception e) {
//            res.statusCode = HttpUtils.HTTP_INTERNAL_SERVER_ERROR;
//            res.responseBody = Blob.valueOf(ErrorResponse.build(res.statusCode, e.getMessage()));
//
//            return ;
//        }

        res.statusCode = HttpUtils.HTTP_OK;
        res.responseBody = Blob.valueOf(JSON.serialize(resMap));
    }
}