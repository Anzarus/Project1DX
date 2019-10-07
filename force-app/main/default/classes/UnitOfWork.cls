/**
 * Created by AntonAntoniuk on 07.10.2019.
 */

public with sharing class UnitOfWork {

    private Set<SObjectType> sObjectTypesToWorkWithDatabase;

    private Map<SObjectType, List<SObject>> toInsert;
    private Map<SObjectType, List<SObject>> toUpdate;
//    private Map<SObjectType, List<SObject>> toUpsert;  todo: do we need upsert?
    private Map<SObjectType, List<SObject>> toDelete;

    private List<Relation> relationsToUpsert;

    public UnitOfWork(Set<SObjectType> sObjectTypes) {
        this.sObjectTypesToWorkWithDatabase = sObjectTypes;
    }

    public void addToInsert(List<SObject> sObjectsToInsert) {
        if (sObjectsToInsert == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toInsert == null) {
            toInsert = new Map<SObjectType, List<SObject>>();
        }

        for (SObject obj : sObjectsToInsert) {
            addToRelationList(obj, null, null, 'insert');
        }
    }

    public void addToInsert(SObject sObjectToInsert) {
        if (sObjectToInsert == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toInsert == null) {
            toInsert = new Map<SObjectType, List<SObject>>();
        }

        addToRelationList(sObjectToInsert, null, null, 'insert');
    }

    public void addToInsert(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toInsert == null) {
            toInsert = new Map<SObjectType, List<SObject>>();
        }

        addToRelationList(child, childFieldToParent, parent, 'insert');
    }

    public void addToUpdate(List<SObject> sObjectsToUpdate) {
        if (sObjectsToUpdate == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }

        for (SObject obj : sObjectsToUpdate) {
            addToRelationList(obj, null, null, 'update');
        }
    }

    public void addToUpdate(SObject sObjectToUpdate) {
        if (sObjectToUpdate == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }

        addToRelationList(sObjectToUpdate, null, null, 'update');
    }

    public void addToUpdate(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }

        addToRelationList(child, childFieldToParent, parent, 'update');
    }
/*

    public void addToUpsert(List<SObject> sObjectsToUpsert) {
        if (sObjectsToUpsert == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toUpsert == null) {
            toUpsert = new Map<SObjectType, List<SObject>>();
        }

        for (SObject obj : sObjectsToUpsert) {
            addToRelationList(obj, null, null, 'upsert');
        }
    }

    public void addToUpsert(SObject sObjectToUpsert) {
        if (sObjectToUpsert == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toUpsert == null) {
            toUpsert = new Map<SObjectType, List<SObject>>();
        }

        addToRelationList(sObjectToUpsert, null, null, 'upsert');
    }

    public void addToUpsert(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toUpsert == null) {
            toUpsert = new Map<SObjectType, List<SObject>>();
        }

        addToRelationList(child, childFieldToParent, parent, 'upsert');
    }
*/

    public void addToDelete(List<SObject> sObjectsToDelete) {
        if (sObjectsToDelete == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toDelete == null) {
            toDelete = new Map<SObjectType, List<SObject>>();
        }

        for (SObject obj : sObjectsToDelete) {
            addToRelationList(obj, null, null, 'delete');
        }
    }

    public void addToDelete(SObject sObjectToDelete) {
        if (sObjectToDelete == null) {
            throw new UnitOfWorkException('Null pointer Exception!');
        }
        if (toDelete == null) {
            toDelete = new Map<SObjectType, List<SObject>>();
        }

        addToRelationList(sObjectToDelete, null, null, 'delete');
    }

    private void addToInsertMap(SObject child) {
        if (!toInsert.containsKey(child.getSObjectType())) {
            toInsert.put(child.getSObjectType(), new List<SObject>());
        }
        toInsert.get(child.getSObjectType()).add(child);
    }

    private void addToUpdateMap(SObject child) {
        if (!toUpdate.containsKey(child.getSObjectType())) {
            toUpdate.put(child.getSObjectType(), new List<SObject>());
        }
        toUpdate.get(child.getSObjectType()).add(child);
    }
/*

    private void addToUpsertMap(SObject child) {
        if (!toUpsert.containsKey(child.getSObjectType())) {
            toUpsert.put(child.getSObjectType(), new List<SObject>());
        }
        toUpsert.get(child.getSObjectType()).add(child);
    }
*/

    private void addToDeleteMap(SObject child) {
        if (!toDelete.containsKey(child.getSObjectType())) {
            toDelete.put(child.getSObjectType(), new List<SObject>());
        }
        toDelete.get(child.getSObjectType()).add(child);
    }

    private void addToRelationList(SObject child, SObjectField childFieldToParent, SObject parent, String operation) {
        isTypeNotMentioned(child);
        if (childFieldToParent == null && parent == null) {
            switch on operation {
                when 'insert' {
                    addToInsertMap(child);
                }
                when 'update' {
                    addToUpdateMap(child);
                }/*
                when 'upsert' {
                    addToUpsertMap(child);
                }*/
                when 'delete' {
                    addToDeleteMap(child);
                }
            }
        } else {
            if (relationsToUpsert == null) relationsToUpsert = new List<UnitOfWork.Relation>();
            relationsToUpsert.add(new Relation(child, childFieldToParent, parent));
        }
    }//todo relations

    @TestVisible
    private void isTypeNotMentioned(SObject obj) {
        if (!sObjectTypesToWorkWithDatabase.contains(obj.getSObjectType())) {
            throw new UnitOfWorkException('SObject type has not been mentioned!');
        }
    }

    public void commitWork() {
        for (SObjectType sObjectType : sObjectTypesToWorkWithDatabase) {
            if (toInsert != null && toInsert.get(sObjectType) != null) {
                tryToLoad(toInsert.get(sObjectType), 'insert');
            }
            if (toUpdate != null && toUpdate.get(sObjectType) != null) {
                tryToLoad(toUpdate.get(sObjectType), 'update');
            }/*
            if (toUpsert != null && toUpsert.get(sObjectType) != null) {
                tryToLoad(toUpsert.get(sObjectType), 'upsert');
            }*/
            if (toDelete != null && toDelete.get(sObjectType) != null) {
                tryToLoad(toDelete.get(sObjectType), 'delete');
            }
        }
    }

    private void tryToLoad(List<SObject> sObjects, String operation) {
        Savepoint savepoint = Database.setSavepoint();
        try {
            switch on operation {
                when 'insert' {
                    insert sObjects;
                }
                when 'update' {
                    update sObjects;
                }/*
                when 'upsert' {
                    upsert sObjects;
                }*/
                when 'delete' {
                    delete sObjects;
                }
            }
        } catch (Exception e) {
            Database.rollback(savepoint);
            throw e;
        }
    }

    private class Relation {
        private SObject child;
        private SObjectField childFieldToParent;
        private SObject parent;

        Relation(SObject child, SObjectField childFieldToParent, SObject parent) {
            if (isFieldNotCorrect(child, childFieldToParent)) {
                throw new UnitOfWorkException('Wrong field!');
            }
            this.child = child;
            this.childFieldToParent = childFieldToParent;
            this.parent = parent;
        }

        private Boolean isFieldNotCorrect(SObject child, SObjectField childFieldToParent) {
            return !child.getSObjectType().getDescribe().fields.getMap().values().contains(childFieldToParent);
        }
    }

    private class UnitOfWorkException extends Exception {
    }
}