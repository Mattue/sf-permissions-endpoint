/**
 * Created by Nikita.Mikhailov on 08.07.2022.
 */

/*******************************************************************************
*  Name            : ErrorResponse
*  Summary         : Object to store REST error (4xx, 5xx) responses
******************************************************************************/
public with sharing class ErrorResponse {
    public Integer statusCode { get; set; }
    public String message { get; set; }

    /*******************************************************************************
    *  Name            : build
    *  Summary         : builds ErrorResponse as JSON
    *  Parameters      : http status code - 4xx, 5xx, etc, message - error of validation message to respond
    *  @return         : ErrorResponse as JSON
    ******************************************************************************/
    public static String build(Integer statusCode, String message) {
        return JSON.serialize(new ErrorResponse(statusCode, message));
    }

    private ErrorResponse(Integer statusCode, String message) {
        this.statusCode = statusCode;
        this.message = message;
    }
}