/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    private Map<String, String> implByInterfaces;

    public DI(Type interfaceType) {
        this.implByInterfaces = putImplsToMap(interfaceType);
    }

    private Map<String, String> putImplsToMap(Type interfaceType) {
        Map<String, String> buffMap = new Map<String, String>();
        List<Product_File_Setting__mdt> impls = [
                SELECT Label, ImplClassName__c
                FROM Product_File_Setting__mdt
                WHERE Interface_Type__c = :interfaceType.toString()
        ];
        for (Product_File_Setting__mdt impl : impls) {
            buffMap.put(impl.Label, impl.ImplClassName__c);
        }
        return buffMap;
    }

    public ServiceConnection getInst(String implType) {
        return (ServiceConnection) Type.forName(implByInterfaces.get(implType)).newInstance();
    }

    public static ServiceConnection overrideInst(String implType, Object mockImpl) {
        if (implByInterfaces.containsKey(implType)) {
            return (ServiceConnection) mockImpl;
        }
        return null;
    }
}