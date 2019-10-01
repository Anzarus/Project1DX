/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    private static Map<String, String> implByInterfaces = new Map<String, String>();

    public static ServiceConnection getInst(Type intfType, String implType) {
        List<Product_File_Setting__mdt> impls = [
                SELECT Interface_Type__c, ImplClassName__c
                FROM Product_File_Setting__mdt
                WHERE Label = :implType
        ];
        for (Product_File_Setting__mdt impl : impls) {
            implByInterfaces.put(impl.Interface_Type__c, impl.ImplClassName__c);
        }

        String str = implByInterfaces.get(intfType.toString());
        Type typee = Type.forName(str);

        return (ServiceConnection) typee.newInstance();
    }

    public static ServiceConnection overrideInst(Type intfType, Object mockImpl) {
        if (implByInterfaces.containsKey(intfType.toString())) {
            return (ServiceConnection) mockImpl;
        }
        return null;
    }
}