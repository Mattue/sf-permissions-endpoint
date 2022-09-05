/**
 * Created by Nikita.Mikhailov on 03.09.2022.
 */

@IsTest
public with sharing class UserPermissionsEndpointTest {

    private static final String URI = '/services/apexrest/perms-api/v1/user-permissions';
    private static User testUser;//TODO: ??? Maybe need to create some freaking user

    @IsTest
    public static void testPost() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI;
        req.params.put('id', UserInfo.getUserId());
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, List<String>>{
                'perms' => new List<String>{
                        'PermissionsEmailSingle'
                },
                'opportunity' => new List<String>{
                        'PermissionsEdit', 'PermissionsRead'
                },
                'lead' => new List<String>{
                        'PermissionsEdit', 'PermissionsRead'
                }
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UserPermissionsEndpoint.doPost();
        Test.stopTest();

        RestResponse response = RestContext.response;

        System.assertEquals(200, response.statusCode);

        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());

        System.assert(responseBody != null && !responseBody.isEmpty());
        System.assertEquals(3, responseBody.size());

        for (Object value : responseBody.values()) {
            System.assert(value instanceof Map<String, Object>);
        }
    }

    @IsTest
    public static void testPostAllPerms() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI;
        req.params.put('id', UserInfo.getUserId());
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, List<String>>{
                'perms' => new List<String>{
                }
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UserPermissionsEndpoint.doPost();
        Test.stopTest();

        RestResponse response = RestContext.response;

        System.assertEquals(200, response.statusCode);

        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());

        System.assert(responseBody != null && !responseBody.isEmpty());
        System.assertEquals(1, responseBody.size());

        for (Object value : responseBody.values()) {
            System.assert(value instanceof Map<String, Object>);
        }
    }

    @IsTest
    public static void testPostAllSObjectAccess() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI;
        req.params.put('id', UserInfo.getUserId());
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, List<String>>{
                'account' => new List<String>{
                }
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UserPermissionsEndpoint.doPost();
        Test.stopTest();

        RestResponse response = RestContext.response;

        System.assertEquals(200, response.statusCode);

        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());

        System.assert(responseBody != null && !responseBody.isEmpty());
        System.assertEquals(1, responseBody.size());

        for (Object value : responseBody.values()) {
            System.assert(value instanceof Map<String, Object>);
        }
    }

    @IsTest
    public static void testPostErrorInPerms() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI;
        req.params.put('id', UserInfo.getUserId());
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, List<String>>{
                'perms' => new List<String>{
                        'not valid perm name'
                }
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UserPermissionsEndpoint.doPost();
        Test.stopTest();

        RestResponse response = RestContext.response;

        System.assertEquals(200, response.statusCode);

        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());

        System.assert(responseBody != null && !responseBody.isEmpty());
        System.assertEquals(1, responseBody.size());

        for (Object value : responseBody.values()) {
            System.assert(value instanceof Map<String, Object>);
        }
    }

    @IsTest
    public static void testPostErrorInSObjectAccess() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI;
        req.params.put('id', UserInfo.getUserId());
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, List<String>>{
                'account' => new List<String>{
                        'not valid perm name'
                }
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UserPermissionsEndpoint.doPost();
        Test.stopTest();

        RestResponse response = RestContext.response;

        System.assertEquals(200, response.statusCode);

        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());

        System.assert(responseBody != null && !responseBody.isEmpty());
        System.assert(response.responseBody.toString().contains('error'));
    }

    @IsTest
    public static void testPost400NoId() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI;
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UserPermissionsEndpoint.doPost();
        Test.stopTest();

        RestResponse response = RestContext.response;

        System.assertEquals(400, response.statusCode);
        System.assert(response.responseBody.toString().contains('id URI param is mandatory'));
    }

    @IsTest
    public static void testPost400EmptyBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI;
        req.params.put('id', UserInfo.getUserId());
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UserPermissionsEndpoint.doPost();
        Test.stopTest();

        RestResponse response = RestContext.response;

        System.assertEquals(400, response.statusCode);
        System.assert(response.responseBody.toString().contains('Body is empty'));
    }

    @IsTest
    public static void testPost400InvalidId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI;
        req.params.put('id', 'not an ID');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, List<String>>{
                'perms' => new List<String>{
                        'PermissionsEmailSingle'
                }
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UserPermissionsEndpoint.doPost();
        Test.stopTest();

        RestResponse response = RestContext.response;

        System.assertEquals(400, response.statusCode);
        System.assert(response.responseBody.toString().contains('Invalid id:'));
    }
}