/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public interface ServiceConnection {

    String getFileDownloadLink(String fileId);

    String sendFile(String fileId);

    String deleteFile(String fileId);
}