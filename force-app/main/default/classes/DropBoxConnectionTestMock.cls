/**
 * Created by AntonAntoniuk on 13.09.2019.
 */

@IsTest
public class DropBoxConnectionTestMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        if (request.getEndpoint() == 'callout:DropBoxGetFile/get_temporary_link') {
            if (request.getBody() == '{\"path\": \"Document.docx\"}') {
                response.setStatusCode(200);
                response.setBody('{"metadata": {}, "link": "https://dl.dropboxusercontent.com/apitl/1/AKed"}');
            } else {
                response.setStatusCode(409);
                response.setBody('Something went wrong!');
            }
        } else if (request.getEndpoint() == 'callout:DropBoxGetFile/delete_batch') {
            if (request.getBody() == '{\"entries\": [{\"path\": \"/file (2).txt\"}, ' +
                    '{\"path\": \"/file (1).txt\"}, ' +
                    '{\"path\": \"/file (1) (1).txt\"}]}') {
                response.setStatusCode(200);
                response.setBody('{".tag": "async_job_id", "async_job_id": "dbjid:AABoqpEIEjq"}');
            } else {
                response.setStatusCode(409);
                response.setBody('Something went wrong!');
            }
        }
        return response;
    }
}