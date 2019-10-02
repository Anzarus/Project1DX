/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    private static Map<ComplexKey, String> implByInterfaces = new Map<ComplexKey, String>();

    static {
        initDI();
    }

    private static void initDI() {
        List<Product_File_Setting__mdt> impls = [
                SELECT Label, Interface_Type__c, ImplClassName__c
                FROM Product_File_Setting__mdt
        ];
        for (Product_File_Setting__mdt impl : impls) {
            implByInterfaces.put(
                    new ComplexKey(Type.forName(impl.Interface_Type__c), impl.Label),
                    impl.ImplClassName__c);
        }
    }

    public static Object getInst(Type interfaceType, String implType) {
        ComplexKey key = findComplexKey(interfaceType, implType);
        if (implByInterfaces.containsKey(key)) {
            try {
                System.debug(implByInterfaces);
                return Type.forName(implByInterfaces.get(key)).newInstance();
            } catch (NullPointerException e) {
                e.setMessage('Impl has not been found!');
            }
        }
        throw new NullPointerException();
    }

    public static void overrideInst(Type interfaceType, String implType, Type mockImpl) {
        ComplexKey key = findComplexKey(interfaceType, implType);
        if (implByInterfaces.containsKey(key)) {
            implByInterfaces.remove(key);
            implByInterfaces.put(key, mockImpl.toString());
        }
    }

    private static ComplexKey findComplexKey(Type type, String implLabel) {
        for (ComplexKey key : implByInterfaces.keySet()) {
            if (key.getType().equals(type)
                    && key.getImplLabel() == implLabel) {
                return key;
            }
        }
        return null;
    }

    private class ComplexKey {
        private Type type;
        private String implLabel;

        ComplexKey(Type type, String implLabel) {
            this.type = type;
            this.implLabel = implLabel;
        }

        Type getType() {
            return this.type;
        }

        String getImplLabel() {
            return this.implLabel;
        }
    }
}