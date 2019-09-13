/**
 * Created by AntonAntoniuk on 12.09.2019.
 */

@IsTest
private class Product2FileFromDropBoxControllerTest {
//    @IsTest
//    static void product2FileFromDropBoxControllerCorrectTest() {
//        Test.setMock(HttpCalloutMock.class, new LinkToFileInDropBoxGetterTestMock());
//        Product2 product2 = new Product2(Name = 'prod', File_Id__c = 'Document.docx', Price__c = 10);
//        insert product2;
//
//        Test.startTest();
//        String link = Product2FileFromDropBoxController.getFileForThisRecord(product2.Id);
//        Test.stopTest();
//
//        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/AKed', link);
//    }

    @IsTest
    static void product2FileFromDropBoxControllerErrorTest() {
        Product2 product2 = new Product2(Name = 'prod', File_Id__c = 'Documentdocx', Price__c = 10);
        insert product2;

        Test.startTest();
        DropBoxConnection dropBox = (DropBoxConnection) MockUtil.createMock(DropBoxConnection.class);
        String link = Product2FileFromDropBoxController.getFileForThisRecord(product2.Id);

        Test.stopTest();

        System.assertEquals('Error 409: Something went wrong!', link);
    }

//    private class LinkToFileInDropBoxGetterTestMock implements HttpCalloutMock {
//
//        private HttpResponse respond(HttpRequest param1) {
//            HttpResponse response = new HttpResponse();
//
//            if (param1.getBody() == '{\"path\": \"Document.docx\"}') {
//                response.setStatusCode(200);
//                response.setBody('{"metadata": {}, "link": "https://dl.dropboxusercontent.com/apitl/1/AKed"}');
//            } else {
//                response.setStatusCode(409);
//                response.setBody('Something went wrong!');
//            }
//            return response;
//        }
//    }

    private class MockProvider implements System.StubProvider {

        private Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
                Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
                List<Object> listOfArgs) {

            if (returnType.getName() == 'HttpResponse') {
                HttpRequest request = (HttpRequest) listOfArgs[0];
                HttpResponse response = new HttpResponse();

                if (request.getBody() == '{\"path\": \"Document.docx\"}') {
                    response.setStatusCode(200);
                    response.setBody('{"metadata": {}, "link": "https://dl.dropboxusercontent.com/apitl/1/AKed"}');
                } else {
                    response.setStatusCode(409);
                    response.setBody('Something went wrong!');
                }
                return response;
            } else {
                return null;
            }
        }
    }

    private class MockUtil {
        private MockUtil() {
        }

        public static MockProvider getInstance() {
            return new MockProvider();
        }

        public static Object createMock(Type typeToMock) {
            // Invoke the stub API and pass it our mock provider to create a
            // mock class of typeToMock.
            return Test.createStub(typeToMock, MockUtil.getInstance());
        }
    }
}