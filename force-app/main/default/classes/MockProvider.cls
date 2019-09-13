/**
 * Created by AntonAntoniuk on 13.09.2019.
 */

@IsTest
public class MockProvider implements System.StubProvider {

    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
            List<Object> listOfArgs) {

        if (stubbedMethodName == 'getDownloadLink') {
            String link;

            if (listOfArgs[0] == '/Document.docx') {
                link = 'https://dl.dropboxusercontent.com/apitl/1/Doc';
            } else if (listOfArgs[0] == '/Test1.1.odt') {
                link = 'https://dl.dropboxusercontent.com/apitl/1/Odt';
            } else {
                throw new DropBoxConnection.DropBoxConnectionException();
            }

            return link;
        } else {
            return null;
        }
    }
}