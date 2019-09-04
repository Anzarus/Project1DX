/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public with sharing class ContactSOQLGenerator {

    public static String generateContactSOQLWithoutWhere() {

        Map<String, Schema.SObjectField> fieldsByStrings = Schema.SObjectType.Contact.fields.getMap();

        String generatedSOQL = '';

        for (String key : fieldsByStrings.keySet()) {
            if (fieldsByStrings.get(key).getDescribe().isAccessible()) {
                generatedSOQL += fieldsByStrings.get(key) + ', ';
            } else {
                throw new NoAccessException();
                /*throw new Exception('Access denied to this field');*/
            }//todo exception case
        }

        /*if (generatedSOQL == '') *//*throw new Exception('Access denied to all fields');*//* {
            throw new NoAccessException();
        }*/

        return 'SELECT ' + generatedSOQL.substring(0, generatedSOQL.length() - 2) +
                ' FROM Contact ';
    }
}