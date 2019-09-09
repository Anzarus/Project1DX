/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public without sharing class SOQLBuilder {

    private String soqlQuery = 'SELECT FROM';
    private Boolean isStrict = false;
    private Boolean withChildToParent = false;
    private List<SObjectField> sObjectFields = new List<SObjectField>();
    private SObjectType sObjectType = null;

    public SOQLBuilder() {
    }

    public SOQLBuilder(Boolean isStrict) {
        this.isStrict = isStrict;
    }

    public SOQLBuilder(Boolean isStrict, Boolean withChildToParent) {
        this.isStrict = isStrict;
        this.withChildToParent = withChildToParent;
    }

    public SOQLBuilder reset() {
        this.soqlQuery = 'SELECT FROM';
        this.isStrict = false;
        this.withChildToParent = false;
        this.sObjectFields = new List<SObjectField>();
        this.sObjectType = null;
        return this;
    }

    public SOQLBuilder setSecurityEnforced() {
        this.soqlQuery += ' WITH SECURITY_ENFORCED';
        return this;
    }

    public SOQLBuilder setFields(SObjectField[] sObjectFields) {
        this.sObjectFields.addAll(sObjectFields);
        for (Integer i = 0; i < sObjectFields.size() - 1; i++) {
            addFieldFromList(i);
        }
        addFieldFromList(sObjectFields.size() - 1);//
        return this;
    }

    public SOQLBuilder setField(SObjectField field) {
        sObjectFields.add(field);
        addFieldFromList(sObjectFields.size() - 1);
        return this;
    }

    public SOQLBuilder setField(String field) {
        Pattern pattern = Pattern.compile('^[A-Z][A-Za-z0-9_]*([A-Z]*[A-Za-z0-9]+(\\.)([A-Z][A-Za-z0-9_]+)+){1,4}$');
        Matcher matcher = pattern.matcher(field);
        if (matcher.matches() /*&& field.countMatches('.') <= 5*/) {
            Integer lastDot = field.lastIndexOf('.');
            SObjectType sObjectType = getSObjectType(field, lastDot);
            if (sObjectType.getDescribe().isAccessible()) {
                SObjectField sObjectField = sObjectType.getDescribe().fields.getMap().get(field.substring(lastDot + 1));
                if (sObjectField.getDescribe().isAccessible()) {
                    addFieldToQuery(field);
                } else if (isStrict) {
                    throw new NoAccessException();
                }
            } else {
                throw new NoAccessException();
            }
        } else {
            throw new BuilderSOQLException('Wrong field: it must look like [SObject].[Field]/[SObject].*.[Field]');
        }
        return this;
    }

    public SOQLBuilder setFrom(SObjectType sObjectType) {
        if (this.sObjectType == null) {
            this.sObjectType = sObjectType;
            if (sObjectType.getDescribe().isAccessible()) {
                soqlQuery = soqlQuery.replace('FROM', 'FROM ' + sObjectType);
            } else {
                throw new NoAccessException();
            }
        } else if (this.sObjectType == sObjectType) {
        } else {
            throw new BuilderSOQLException('Setting another sObject without reset!');
        }
        return this;
    }

    public SOQLBuilder setFrom(String sObj) {
        SObjectType newSObjectType = getSObjectType(sObj, sObj.length());
        if (sObjectType == null) {
            sObjectType = newSObjectType;
            if (sObjectType.getDescribe().isAccessible()) {
                soqlQuery = soqlQuery.replace('FROM', 'FROM ' + sObj);
            } else {
                throw new NoAccessException();
            }
        } else if (sObjectType == newSObjectType) {
        } else {
            throw new BuilderSOQLException();
        }
        return this;
    }

    public String build() {
        if (soqlQuery.substringBetween('SELECT', 'FROM').trim() == ''
                || soqlQuery.substringAfter('FROM'/*,Where*/).trim() == '') {
            throw new BuilderSOQLException('Miss field(s) or object expression');
        }
        return this.soqlQuery;
    }

    private void addFieldFromList(Integer place) {
        if (sObjectFields.get(place).getDescribe().isAccessible()) {
            if (withChildToParent) {
                addFieldToQuery(String.valueOf(getSObjectType(sObjectFields.get(place))),
                        String.valueOf(sObjectFields.get(place)));
            } else {
                addFieldToQuery(String.valueOf(sObjectFields.get(place)));
            }

        } else if (isStrict) {
            throw new NoAccessException();
        }
    }

    private void addFieldToQuery(String field) {
        if (soqlQuery.contains(',')
                || soqlQuery.substringBetween('SELECT', 'FROM').trim() != '') {
            soqlQuery = soqlQuery.replace(' FROM', ', ' + field + ' FROM');
        } else {
            soqlQuery = soqlQuery.replace('FROM', field + ' FROM');
        }
    }

    private void addFieldToQuery(String sObj, String field) {
        if (soqlQuery.contains(',')
                || soqlQuery.substringBetween('SELECT', 'FROM').trim() != '') {
            soqlQuery = soqlQuery.replace(' FROM', ', ' + sObj + '.' + field + +' FROM');
        } else {
            soqlQuery = soqlQuery.replace('FROM', sObj + '.' + field + ' FROM');
        }
    }

    private SObjectType getSObjectType(String field, Integer lastDot) {
        String objects = field.substring(0, lastDot);
        SObjectType lastObj;
        if (field.contains('.')) {
            String obj = objects.substringBefore('.');
            lastObj = Schema.getGlobalDescribe().get(obj);
        } else {
            lastObj = Schema.getGlobalDescribe().get(objects);
        }
        /*for (String obj : objects.split('\\.')) {
            lastObj = Schema.getGlobalDescribe().get(obj);
            if (lastObj.getDescribe().isAccessible()) {
                continue;
            } else if (isStrict) {
                throw new NoAccessException();
            }
        }*/
        return lastObj;
    }

    private SObjectType getSObjectType(SObjectField sObjectField) {
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Map<Integer, SObjectType> objectTypesByFieldsHashes = new Map<Integer, SObjectType>();

        for (String sObjectName : globalDescribe.keySet()) {
            for (SObjectField field : globalDescribe.get(sObjectName).getDescribe().fields.getMap().values()) {
                objectTypesByFieldsHashes.put(((Object) field).hashCode(), globalDescribe.get(sObjectName));
            }
        }

        return objectTypesByFieldsHashes.get(((Object) sObjectField).hashCode());
    }

    public class BuilderSOQLException extends Exception {
    }
}