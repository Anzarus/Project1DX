/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public with sharing class SOQLGenerator {

    private SObjectType sObjectType;

    public SOQLGenerator(SObjectType sObjectType) {
        this.sObjectType = sObjectType;
    }

    public String generateSOQL(){
        Map<String, Schema.SObjectField> fieldsByStrings = sObjectType.getDescribe().fields.getMap();

        String generatedSOQL = '';

        for (String key : fieldsByStrings.keySet()){
            if (fieldsByStrings.get(key).getDescribe().isAccessible()) {
                generatedSOQL += fieldsByStrings.get(key) + ', ';
            } else {
                /*throw new Exception('Access denied to this field');*/
            }//todo exception case
        }

        if (generatedSOQL == '') /*throw new Exception('Access denied to all fields');*/ {
            return '';
        }//todo error case

        return 'SELECT ' + generatedSOQL.substring(0, generatedSOQL.length() - 2) +
                ' FROM ' + sObjectType + ' ';
    }

}