/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class DI {

    private static Map<ComplexKey, String> implByInterfaces = new Map<ComplexKey, String>();

    static {
        formMap(new SOQLPostman());
    }

    @TestVisible
    private static void formMap(SOQLPostman postman) {
        String query = new SOQLBuilder()
                .setFrom(Product_File_Setting__mdt.SObjectType)
                .setFields(new SObjectField[]{
                        Product_File_Setting__mdt.Label,
                        Product_File_Setting__mdt.Interface_Type__c,
                        Product_File_Setting__mdt.ImplClassName__c
                })
                .build();

        List<Product_File_Setting__mdt> impls = (List<Product_File_Setting__mdt>) postman.sendQuery(query);

        for (Product_File_Setting__mdt impl : impls) {
            implByInterfaces.put(
                    new ComplexKey(Type.forName(impl.Interface_Type__c), impl.Label),
                    impl.ImplClassName__c);
        }
    }

    public static Object getInst(Type interfaceType, String implType) {
        ComplexKey key = new ComplexKey(interfaceType, implType);
        if (implByInterfaces.containsKey(key)) {
            return Type.forName(implByInterfaces.get(key)).newInstance();
        }
        throw new DIException('Impl has not been found!');
    }

    public static void overrideInst(Type interfaceType, String implType, Type mockImpl) {
        ComplexKey key = new ComplexKey(interfaceType, implType);
        if (implByInterfaces.containsKey(key)) {
            implByInterfaces.remove(key);
            implByInterfaces.put(key, mockImpl.toString());
        }
    }

    private class ComplexKey {
        private Type type;
        private String impl;

        ComplexKey(Type type, String implLabel) {
            this.type = type;
            this.impl = implLabel;
        }

        Boolean equals(Object that) {
            if (that != null && that instanceof ComplexKey) {
                ComplexKey thatKey = (ComplexKey) that;
                return type == thatKey.type
                        && impl == thatKey.impl;
            }
            return false;
        }

        Integer hashCode() {
            Integer h = 17 + 31 * type.hashCode();
            h += 31 * impl.hashCode();
            return h;
        }
    }

    private class DIException extends Exception {
    }
}