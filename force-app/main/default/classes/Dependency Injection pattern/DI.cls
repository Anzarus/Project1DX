/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    private static Map<Integer, String> implByInterfaces = new Map<Integer, String>();

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
                    new ComplexKey(Type.forName(impl.Interface_Type__c), impl.Label).hashCode(),
                    impl.ImplClassName__c);
        }
    }

    public static Object getInst(Type interfaceType, String implType) {
        Integer key = new ComplexKey(interfaceType, implType).hashCode();
        if (implByInterfaces.containsKey(key)) {
            System.debug(implByInterfaces);
            return Type.forName(implByInterfaces.get(key)).newInstance();
        }
        throw new DIException('Impl has not been found!');
    }

    public static void overrideInst(Type interfaceType, String implType, Type mockImpl) {
        Integer key = new ComplexKey(interfaceType, implType).hashCode();
        if (implByInterfaces.containsKey(key)) {
            implByInterfaces.remove(key);
            implByInterfaces.put(key, mockImpl.toString());
        }
    }

    private class ComplexKey {
        private Type type;
        private String implLabel;

        ComplexKey(Type type, String implLabel) {
            this.type = type;
            this.implLabel = implLabel;
        }

        Integer hashCode() {
            return type.hashCode() * implLabel.hashCode();
        }
    }

    private class DIException extends Exception {
    }
}