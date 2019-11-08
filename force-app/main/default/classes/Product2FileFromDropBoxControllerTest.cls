/**
 * Created by AntonAntoniuk on 12.09.2019.
 */

@IsTest
public class Product2FileFromDropBoxControllerTest {

    @IsTest
    static void product2FileFromDropBoxControllerSuccessWithSavingLinkTest() {
        List<Product2> product2s = new List<Product2>{
                new Product2(Name = 'prod1', File_Id__c = '/Document.docx', Price__c = 10),
                new Product2(Name = 'prod2', File_Id__c = '/Test1.1.odt', Price__c = 10)
        };
        insert product2s;

        Test.startTest();
        DropBoxFileLinkFabric fabric = (DropBoxFileLinkFabric) Test.createStub(DropBoxFileLinkFabric.class, new MockProvider());
        Product2FileFromDropBoxController.fabric = fabric;

        String linkSecondTime1 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[0].Id);
        String linkFirstTime2 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[1].Id);
        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', linkSecondTime1);
        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Odt', linkFirstTime2);
    }

    @IsTest
    static void product2FileFromDropBoxControllerDropBoxHasFileTest() {
        List<Product2> product2s = new List<Product2>{
                new Product2(Name = 'prod1', File_Id__c = '', Price__c = 10),
                new Product2(Name = 'prod1', File_Id__c = '/Document.docx', Price__c = 10)
        };
        insert product2s;

        System.assertEquals(false, Product2FileFromDropBoxController.isProdHasFile(product2s[0].Id));
        System.assertEquals(true, Product2FileFromDropBoxController.isProdHasFile(product2s[1].Id));
    }

    public class DropBoxConnectionTestImpl implements DropBoxConnection {

        public String getDownloadLink(String pathToFile) {
            if (pathToFile == '/Document.docx') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Doc';
            } else if (pathToFile == '/Test1.1.odt') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Odt';
            } else {
                return '';
            }
        }
    }
}