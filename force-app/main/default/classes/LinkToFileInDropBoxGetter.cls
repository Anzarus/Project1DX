/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class LinkToFileInDropBoxGetter {

    public static String getLink(String pathToFile) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint('callout:DropBoxAuthByPass');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer 6MsxBLzc8TAAAAAAAAAAE-3P6maCjSJh2mdpeSCLJEwCKr8MBAF6m7ZB1_-QZIcH');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"path\": \"' + pathToFile + '\"}');

        HttpResponse result = http.send(request);

        if (result.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
            return String.valueOf(resultMap.get('link'));
        }
        return 'Error ' + result.getStatusCode();
    }
}