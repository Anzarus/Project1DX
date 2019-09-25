/**
 * Created by AntonAntoniuk on 12.09.2019.
 */

@IsTest
public class Product2FileFromDropBoxControllerTest {

    @IsTest
    static void product2FileFromDropBoxControllerSuccessWithSavingLinkTest() {
        List<Product2> product2s = new List<Product2>{
                new Product2(Name = 'prod1', Price__c = 10),
                new Product2(Name = 'prod2', Price__c = 10)
        };
        insert product2s;

        List<File_Source__c> files = new List<File_Source__c>{
                new File_Source__c(Name = '/Document1.docx', Product__c = product2s[0].Id),
                new File_Source__c(Name = '/Document2.docx', Product__c = product2s[0].Id),
                new File_Source__c(Name = '/Test1.1.odt', Product__c = product2s[1].Id)
        };
        insert files;

        Test.startTest();
        DropBoxFileLinkFabric fabric = (DropBoxFileLinkFabric) Test.createStub(DropBoxFileLinkFabric.class, new MockProvider());
        Product2FileFromDropBoxController.fabric = fabric;

        List<String> linksProd1 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[0].Id);
        List<String> linksProd2 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[1].Id);

        Test.stopTest();

        System.assertEquals(new List<String>{
                'https://dl.dropboxusercontent.com/apitl/1/Doc1',
                'https://dl.dropboxusercontent.com/apitl/1/Doc2'
        }, linksProd1);
        System.assertEquals(new List<String>{
                'https://dl.dropboxusercontent.com/apitl/1/Odt'
        }, linksProd2);
    }

    @IsTest
    static void product2FileFromDropBoxControllerDropBoxHasFileTest() {
        List<Product2> product2s = new List<Product2>{
                new Product2(Name = 'prod1', Price__c = 10),
                new Product2(Name = 'prod1', Price__c = 10)
        };
        insert product2s;

        File_Source__c file = new File_Source__c(Name = '/Document.docx', Product__c = product2s[1].Id);
        insert file;

        System.assertEquals(false, Product2FileFromDropBoxController.isProdHasFile(product2s[0].Id));
        System.assertEquals(true, Product2FileFromDropBoxController.isProdHasFile(product2s[1].Id));
    }

    public class DropBoxConnectionTestImpl implements DropBoxConnection {

        public String getDownloadLink(String pathToFile) {
            if (pathToFile == '/Document1.docx') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Doc1';
            } else if (pathToFile == '/Test1.1.odt') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Odt';
            } else if (pathToFile == '/Document2.docx') {
                return 'https://dl.dropboxusercontent.com/apitl/1/Doc2';
            } else {
                return '';
            }
        }
    }
}