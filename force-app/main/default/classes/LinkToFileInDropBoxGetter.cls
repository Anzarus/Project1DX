/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class LinkToFileInDropBoxGetter {

    public static String getLink(String pathToFile) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();

//        request.setEndpoint('callout:DropBoxGetFile');
        request.setEndpoint('callout:DropBoxViewFile');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer 6MsxBLzc8TAAAAAAAAAAFG-LXrMO3gotZuw71Aofb0y6J68Ip4kXYjvabhDDqy6i');
//        request.setHeader('Content-Type', 'application/json');
//        request.setBody('{\"path\": \"' + pathToFile + '\"}');
        request.setHeader('Dropbox-API-Arg', '{\"path\": \"' + pathToFile + '\"}');
        HttpResponse result = http.send(request);

        if (result.getStatusCode() == 200) {
//            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
            return /*String.valueOf(resultMap.get('link'))*/result.getBody();
        }
        return 'Error ' + result.getStatusCode();
    }
}