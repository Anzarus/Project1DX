/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public with sharing class ContactSOQLGenerator {

    private Boolean isStrict = false;

    public ContactSOQLGenerator() {}

    public ContactSOQLGenerator(Boolean isStrict) {
        this.isStrict = isStrict;
    }

    public void setIsStrict(Boolean isStrict){
        this.isStrict = isStrict;
    }

    public String generateContactSOQLWithoutWhere() {

        Map<String, Schema.SObjectField> fieldsByStrings = Schema.SObjectType.Contact.fields.getMap();

        String generatedSOQL = '';

        for (String key : fieldsByStrings.keySet()) {
            if (fieldsByStrings.get(key).getDescribe().isAccessible()) {
                generatedSOQL += fieldsByStrings.get(key) + ', ';
            } else if (isStrict) {
                throw new NoAccessException();
            }
        }

        return 'SELECT ' + generatedSOQL.substring(0, generatedSOQL.length() - 2) +
                ' FROM Contact ';
    }
}