/**
 * Created by AntonAntoniuk on 02.10.2019.
 */

public with sharing class SOQLPostman {
    public List<SObject> sendQuery(String query) {
        return Database.query(query);
    }
}