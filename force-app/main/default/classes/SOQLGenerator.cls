/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public with sharing class SOQLGenerator {

    private SObjectType sObjectType;
    private Boolean isStrict = false;

    public SOQLGenerator(SObjectType sObjectType) {
        this.sObjectType = sObjectType;
    }

    public SOQLGenerator(SObjectType sObjectType, Boolean isStrict) {
        this.sObjectType = sObjectType;
        this.isStrict = isStrict;
    }

    public void setIsStrict(Boolean isStrict){
        this.isStrict = isStrict;
    }

    public String generateSOQL() {
        Map<String, Schema.SObjectField> fieldsByStrings = sObjectType.getDescribe().fields.getMap();

        String generatedSOQL = '';

        for (String key : fieldsByStrings.keySet()) {
            if (fieldsByStrings.get(key).getDescribe().isAccessible()) {
                generatedSOQL += fieldsByStrings.get(key) + ', ';
            } else if (isStrict) {
                throw new NoAccessException();
            }
        }

        return 'SELECT ' + generatedSOQL.substring(0, generatedSOQL.length() - 2) +
                ' FROM ' + sObjectType + ' ';
    }

}