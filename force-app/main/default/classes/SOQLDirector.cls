/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public with sharing class SOQLDirector {

    public void generateSOQLQuery(SOQLBuilder soqlBuilder){
        soqlBuilder.reset();
        soqlBuilder.setSelect();
        soqlBuilder.setFields();
        soqlBuilder.setFrom();
        soqlBuilder.setObject();
    }
}