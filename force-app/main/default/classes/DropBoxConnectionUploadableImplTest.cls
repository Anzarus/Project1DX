/**
 * Created by AntonAntoniuk on 07.11.2019.
 */

@IsTest
private class DropBoxConnectionUploadableImplTest {
    @IsTest
    static void testGetLink() {
        DropBoxConnectionImpl connection = (DropBoxConnectionImpl) Test.createStub(DropBoxConnectionImpl.class, new MockProvider());
        DropBoxConnectionUploadableImpl connectionUploadable = new DropBoxConnectionUploadableImpl(connection);

        String result = connectionUploadable.getDownloadLink('/Document.docx');

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', result);
    }

    @IsTest
    static void uploadFileSuccessTest() {
        String responseBody = '{' +
                '"name": "Document.docx",' +
                '"size": 7212,' +
                '"path_display": "/Document.docx"' +
                '}';
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        Test.startTest();
        String result = new DropBoxConnectionUploadableImpl(new DropBoxConnectionImpl()).uploadFile(
                '/Document.docx',
                Blob.valueOf('content')
        );
        Test.stopTest();

        System.assertEquals('/Document.docx', result);
    }

    @IsTest
    static void uploadFileErrorTest() {
        String responseBody = 'Something went wrong!';
        HttpResponse response = new HttpResponse();
        response.setStatusCode(400);
        response.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        try {
            Test.startTest();
            new DropBoxConnectionUploadableImpl(new DropBoxConnectionImpl()).uploadFile(
                    '.',
                    Blob.valueOf('content')
            );
            Test.stopTest();
        } catch (DropBoxConnectionUploadableImpl.DropBoxConnectionException e) {
            System.assertEquals('Something went wrong!', e.getMessage());
        }
    }

    private class DropBoxConnectionTestMock implements HttpCalloutMock {

        HttpResponse httpResponse;

        private DropBoxConnectionTestMock(HttpResponse httpResponse) {
            this.httpResponse = httpResponse;
        }

        public HttpResponse respond(HttpRequest request) {
            return this.httpResponse;
        }
    }
}