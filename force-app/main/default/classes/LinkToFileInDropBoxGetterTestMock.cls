/**
 * Created by AntonAntoniuk on 11.09.2019.
 */
@IsTest
public class LinkToFileInDropBoxGetterTestMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest param1) {
        HttpResponse response = new HttpResponse();

        if (param1.getBody() == '{\"path\": \"Document.docx\"}') {
            response.setStatusCode(200);
            response.setBody('{"metadata": {}, "link": "https://dl.dropboxusercontent.com/apitl/1/AKed"}');
        } else {
            response.setStatusCode(409);
            response.setBody('Something went wrong!');
        }
        return response;
    }
}