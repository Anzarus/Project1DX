/**
 * Created by AntonAntoniuk on 16.09.2019.
 */

public interface DropBoxConnection {

    String getDownloadLink(String fileId);

    String uploadFile(String fileId, Blob fileContent);//todo ask about this method cause of creation in new interface
}