/**
 * Created by AntonAntoniuk on 13.09.2019.
 */

@IsTest
public class MockProvider implements System.StubProvider {

    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
            List<Object> listOfArgs) {

        if (stubbedMethodName == 'getDropBoxConnector') {
            DropBoxConnection connection = new Product2FileFromDropBoxControllerTest.DropBoxConnectionTestImpl();
            return connection;
        } else if (stubbedMethodName == 'hasCache') {
            String key1 = String.valueOf('/Document.docx'.hashCode());
            if (listOfArgs[0] == key1) {
                return true;
            }
            return false;
        } else if (stubbedMethodName == 'getCache') {
            String key1 = String.valueOf('/Document.docx'.hashCode());
            String key2 = String.valueOf('/Test1.1.odt'.hashCode());
            if (listOfArgs[0] == key1) {
                return 'https://dl.dropboxusercontent.com/apitl/1/Doc';
            } else if (listOfArgs[0] == key2) {
                return 'https://dl.dropboxusercontent.com/apitl/1/Odt';
            }
            return null;
        } else if (stubbedMethodName == 'getDownloadLink') {
            if (listOfArgs[0] == '/Document.docx') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Doc';
            } else if (listOfArgs[0] == '/Test1.1.odt') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Odt';
            }
            return null;
        } else if (stubbedMethodName == 'uploadFile') {
            if (listOfArgs[0].equals('/Document.docx') &&
                    EncodingUtil.base64Encode((Blob) listOfArgs[1]).equals(EncodingUtil.base64Encode(Blob.valueOf('content')))) {
                return '/Document.docx';
            }
            return null;
        } else {
            return null;
        }
    }
}