/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public with sharing class SOQLBuilderUnit implements SOQLBuilder {

    private SObjectType sObjectType;
    private List<SObjectField> sObjectFields;
    private String soqlQuery;
    private Boolean isStrict = false;

    public SOQLBuilderUnit(SObjectType sObjectType,
            List<SObjectField> sObjectFields) {
        this.sObjectType = sObjectType;
        this.sObjectFields = sObjectFields;
    }

    public SOQLBuilderUnit(SObjectType sObjectType,
            List<SObjectField> sObjectFields,
            Boolean isStrict) {
        this.sObjectType = sObjectType;
        this.sObjectFields = sObjectFields;
        this.isStrict = isStrict;
    }

    public void reset() {
        this.soqlQuery = '';
    }

    public void setSelect() {
        this.soqlQuery += 'SELECT ';
    }

    public void setFields() {
        for (Integer i = 0; i < sObjectFields.size() - 1; i++) {
            addFieldToSOQL(i, ', ');
        }
        addFieldToSOQL(sObjectFields.size() - 1, ' ');
    }

    public void setFrom() {
        this.soqlQuery += 'FROM ';
    }

    public void setObject() {
        this.soqlQuery += this.sObjectType + ' ';
    }

    public String getSOQL() {
        return this.soqlQuery;
    }

    public void setIsStrict(Boolean isStrict) {
        this.isStrict = isStrict;
    }

    private void addFieldToSOQL(Integer place, String separator) {
        if (sObjectFields.get(place).getDescribe().isAccessible()) {
            soqlQuery += sObjectFields.get(place) + separator;
        } else if (isStrict) {
            throw new NoAccessException();
        }
    }
}