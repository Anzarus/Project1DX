/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public with sharing class SOQLBuilderWithoutThrowingExceptions implements SOQLBuilder {

    private SObjectType sObjectType;
    private List<SObjectField> sObjectFields;
    private String soqlQuery;

    public SOQLBuilderWithoutThrowingExceptions(SObjectType sObjectType, List<SObjectField> sObjectFields) {
        this.sObjectType = sObjectType;
        this.sObjectFields = sObjectFields;
    }

    public void reset() {
        this.soqlQuery = '';
    }

    public void setSelect() {
        this.soqlQuery += 'SELECT ';
    }

    public void setFields() {
        for (Integer i = 0; i < sObjectFields.size() - 1; i++) {
            if (sObjectFields.get(i).getDescribe().isAccessible()) {
                addFieldToSOQL(i, ', ');
            }else {
                throw new NoAccessException();
            }
        }
        addFieldToSOQL(sObjectFields.size() - 1,' ');
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

    private void addFieldToSOQL(Integer place, String separator) {
        soqlQuery += sObjectFields.get(place) + separator;
    }
}