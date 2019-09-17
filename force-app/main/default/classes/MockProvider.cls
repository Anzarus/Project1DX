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
            switch on String.valueOf(listOfArgs[0]) {
                when '/Document.docx' {
                    link = 'https://dl.dropboxusercontent.com/apitl/1/Doc';
                }
                when '/Test1.1.odt' {
                    link = 'https://dl.dropboxusercontent.com/apitl/1/Odt';
                }
                when else {
                    throw new DropBoxConnection.DropBoxConnectionException();
                }
            }
            return link;
        } else if (stubbedMethodName == 'hasCache') {
            if (listOfArgs[0] == '/Document.docx') {
                return true;
            }
            return false;
        } else if (stubbedMethodName == 'getCache') {
            if (listOfArgs[0] == '/Document.docx') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Doc';
            } else if (listOfArgs[0] == '/Test1.1.odt') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Odt';
            }
            return null;


        } else {
            return null;
        }
    }
}