/**
 * Created by AntonAntoniuk on 16.09.2019.
 */

public virtual with sharing class DropBoxConnectionBaseDecorator implements DropBoxConnectionInterface {

    private DropBoxConnectionInterface wrappee;

    public DropBoxConnectionBaseDecorator(DropBoxConnectionInterface wrappee) {
        this.wrappee = wrappee;
    }

    public virtual String getDownloadLink(String pathToFile) {
        return (String) wrappee.getDownloadLink(pathToFile);
    }
}