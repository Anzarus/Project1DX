/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

public interface DropBoxConnectionUploadable extends DropBoxConnection{

    String uploadFile(String fileId, String fileContent);
}