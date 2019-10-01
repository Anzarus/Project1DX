/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    public static ServiceConnection getInst(Type type, String implType) {
        Product_File_Setting__mdt setting = [
                SELECT ImplClassName__c
                FROM Product_File_Setting__mdt
                WHERE Label = :implType
        ];

        return (ServiceConnection) type.forName(setting.ImplClassName__c).newInstance();
    }

    public static ServiceConnection overrideInst() {

    }
}