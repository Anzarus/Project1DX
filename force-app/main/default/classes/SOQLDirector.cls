/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public with sharing class SOQLDirector {

    public void generateSOQLQueryWithStrictAccessRules(SOQLBuilder soqlBuilder){
        soqlBuilder.reset();
        soqlBuilder.setSelect();
        soqlBuilder.setFields();
        soqlBuilder.setFrom();
        soqlBuilder.setObject();
    }

    public void generateSOQLQueryWithoutStrictAccessRules(SOQLBuilder soqlBuilder){
        soqlBuilder.reset();
        soqlBuilder.setIsStrict(true);
        soqlBuilder.setSelect();
        soqlBuilder.setFields();
        soqlBuilder.setFrom();
        soqlBuilder.setObject();
    }
}