/**
 * Created by AntonAntoniuk on 11.09.2019.
 */
@IsTest
public with sharing class LinkToFileInDropBoxGetterTest {
    @IsTest
    static void getLinkSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new LinkToFileInDropBoxGetterTestMock());
        String link = LinkToFileInDropBoxGetter.getLink('Document.docx');

        System.assertEquals(link, 'https://dl.dropboxusercontent.com/apitl/1/AKed');
    }

    @IsTest
    static void getLinkErrorTest() {
        Test.setMock(HttpCalloutMock.class, new LinkToFileInDropBoxGetterTestMock());
        String link = LinkToFileInDropBoxGetter.getLink('Documentdocx');

        System.assertEquals('Error 409', link);
    }
}
