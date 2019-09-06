/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public without sharing class SOQLBuilder {

    private String soqlQuery = 'SELECT FROM';
    private Boolean isStrict = false;
    private Boolean withChildToParent = false;
    private List<SObjectField> sObjectFields = null;
    private SObjectType sObjectType = null;

    public SOQLBuilder() {
    }
/*
    public SOQLBuilder(Boolean withChildToParent) {
        this.withChildToParent = withChildToParent;
    }*/

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
        this.sObjectFields = null;
        this.sObjectType = null;
        return this;
    }

    public SOQLBuilder setFields(List<SObjectField> sObjectFields) {
        this.sObjectFields = sObjectFields;
        for (Integer i = 0; i < sObjectFields.size() - 1; i++) {
            addFieldFromList(i);
        }
        addFieldFromList(sObjectFields.size() - 1);//
        return this;
    }

    public SOQLBuilder setField(SObjectField field) {
        if (field.getDescribe().isAccessible()) {
            addFieldToQuery(String.valueOf(field));//
        } else if (isStrict) {
            throw new NoAccessException();
        }
        return this;
    }

    public SOQLBuilder setField(String field) {
        Pattern pattern = Pattern.compile('^[A-Z][A-Za-z0-9_]*([A-Z]*[A-Za-z0-9]+(\\.)([A-Z][A-Za-z0-9_]+)+){1,4}$');
        Matcher matcher = pattern.matcher(field);
        if (matcher.matches() /*&& field.countMatches('.') <= 5*/) {
            Integer lastDot = field.lastIndexOf('.');
            SObjectField sObjectField = getSObjectType(field, lastDot)
                    .getDescribe().fields.getMap().get(field.substring(lastDot + 1));

            if (sObjectField.getDescribe().isAccessible()) {
                addFieldToQuery(String.valueOf(sObjectField));//
            } else if (isStrict) {
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
            throw new BuilderSOQLException();
        }
        return this;
    }

    public SOQLBuilder setFrom(String sObj) {
        if (sObjectType == null) {
            sObjectType = getSObjectType(sObj, sObj.length());
            if (sObjectType.getDescribe().isAccessible()) {
                soqlQuery = soqlQuery.replace('FROM', 'FROM ' + sObj);
            } else {
                throw new NoAccessException();
            }
        } else if (sObjectType == getSObjectType(sObj, sObj.length())) {
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
            addFieldToQuery(String.valueOf(sObjectFields.get(place)));//
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

    private void addFieldToQueryWithRelation(String field, String sObj) {//todo get usage of this method
        if (soqlQuery.contains(',')
                || soqlQuery.substringBetween('SELECT', 'FROM').trim() != '') {
            soqlQuery = soqlQuery.replace(' FROM', ', ' + sObj + '.' + field + +' FROM');
        } else {
            soqlQuery = soqlQuery.replace('FROM', sObj + '.' + field + ' FROM');
        }
    }

    private SObjectType getSObjectType(String field, Integer lastDot) {
        String obj;
        if (field.countMatches('.') > 1) {
            String str = field.substring(0, lastDot);
            lastDot = str.lastIndexOf('.');
            obj = str.substring(lastDot + 1, str.length());
        } else {
            obj = field.substring(0, lastDot);
        }
        return Schema.getGlobalDescribe().get(obj);
    }

    private class BuilderSOQLException extends Exception {
    }
}