/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    private static Map<String, String> implByInterfaces = new Map<String, String>();

    public static ServiceConnection getInst(Type intfType, String implType) {
        List<Product_File_Setting__mdt> impls = [
                SELECT Label, ImplClassName__c
                FROM Product_File_Setting__mdt
                WHERE Label = :implType AND Interface_Type__c = :intfType.toString()
        ];
        for (Product_File_Setting__mdt impl : impls) {
            implByInterfaces.put(impl.Label, impl.ImplClassName__c);
        }
        return (ServiceConnection) Type.forName(implByInterfaces.get(implType)).newInstance();
    }

    public static ServiceConnection overrideInst(String implType, Object mockImpl) {
        if (implByInterfaces.containsKey(implType)) {
            return (ServiceConnection) mockImpl;
        }
        return null;
    }
}