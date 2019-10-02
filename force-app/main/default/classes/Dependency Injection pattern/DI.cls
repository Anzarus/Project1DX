/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    private Map<String, String> implByInterfaces;

    public DI(Type interfaceType) {
        this.implByInterfaces = new Map<String, String>();

        List<Product_File_Setting__mdt> impls = [
                SELECT Label, ImplClassName__c
                FROM Product_File_Setting__mdt
                WHERE Interface_Type__c = :interfaceType.toString()
        ];
        for (Product_File_Setting__mdt impl : impls) {
            implByInterfaces.put(impl.Label, impl.ImplClassName__c);
        }
    }

    public ServiceConnection getInst(String implType) {
        String str = implByInterfaces.get(implType.toString());
        Type typee = Type.forName(str);

        return (ServiceConnection) typee.newInstance();
    }

    public ServiceConnection overrideInst(String implType,Object mockImpl) {
        if (implByInterfaces.containsKey(implType.toString())) {
            return (ServiceConnection) mockImpl;
        }
        return null;
    }
}