/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    private static Map<Type, Map<String, String>> implByInterfaces = new Map<Type, Map<String, String>>();

    static {
        initDI();
    }

    private static void initDI() {
        List<Product_File_Setting__mdt> impls = [
                SELECT Interface_Type__c, Label, ImplClassName__c
                FROM Product_File_Setting__mdt
        ];
        for (Product_File_Setting__mdt impl : impls) {
            if (!implByInterfaces.containsKey(Type.forName(impl.Interface_Type__c))) {
                implByInterfaces.put(Type.forName(impl.Interface_Type__c), new Map<String, String>{
                        impl.Label => impl.ImplClassName__c
                });
            } else {
                implByInterfaces.get(Type.forName(impl.Interface_Type__c)).put(impl.Label, impl.ImplClassName__c);
            }
        }
    }

    public static Object getInst(Type interfaceType, String implType) {
        if (implByInterfaces.containsKey(interfaceType)) {
            if (implByInterfaces.get(interfaceType).containsKey(implType)) {
                try {
                    return Type.forName(implByInterfaces.get(interfaceType).get(implType)).newInstance();
                } catch (NullPointerException e) {
                    e.setMessage('Impl has not been found!');
                }
            }
        }
        throw new NullPointerException();
    }

    public static void overrideInst(Type interfaceType, String implType, Type mockImpl) {
        if (implByInterfaces.containsKey(interfaceType)) {
            if (implByInterfaces.get(interfaceType).containsKey(implType)) {
                implByInterfaces.get(interfaceType).remove(implType);
                implByInterfaces.get(interfaceType).put(implType, mockImpl.toString());
            }
        }
    }
}