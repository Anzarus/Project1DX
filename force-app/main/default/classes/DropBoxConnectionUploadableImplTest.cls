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
    static void testUploadFile() {
        DropBoxConnectionImpl connection = (DropBoxConnectionImpl) Test.createStub(DropBoxConnectionImpl.class, new MockProvider());
        DropBoxConnectionUploadableImpl connectionUploadable = new DropBoxConnectionUploadableImpl(connection);

        String result = connectionUploadable.uploadFile('/Document.docx', Blob.valueOf('content'));

        System.assertEquals('/Document.docx', result);
    }
}