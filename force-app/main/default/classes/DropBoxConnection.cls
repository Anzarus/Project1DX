/**
 * Created by AntonAntoniuk on 16.09.2019.
 */

public interface DropBoxConnection {

    String getDownloadLink(String pathToFile);

    String uploadFile(String filePath, String fileContent);
}