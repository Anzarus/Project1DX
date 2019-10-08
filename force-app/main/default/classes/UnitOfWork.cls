/**
 * Created by AntonAntoniuk on 07.10.2019.
 */

public with sharing class UnitOfWork {
    private Set<SObjectType> sObjectTypesToWorkWithDatabase;

    private Map<SObjectType, List<SObject>> toInsert;
    private Map<SObjectType, List<SObject>> toUpdate;
    private Map<SObjectType, List<SObject>> toDelete;

    private List<Relation> relationsToUpsert;
    private List<SObject> childrenWithRelationsToUpdate;

    private enum TypeOfDMLOperation {
        DML_Insert, DML_Update, DML_Delete
    }

    public UnitOfWork(Set<SObjectType> sObjectTypes) {
        this.sObjectTypesToWorkWithDatabase = sObjectTypes;
    }

    public void addToInsert(List<SObject> sObjectsToInsert) {
        if (sObjectsToInsert == null || sObjectsToInsert.size() == 0) {
            throw new UnitOfWorkException('The list should be initialized and have at list one value!');
        }
        if (toInsert == null) {
            toInsert = new Map<SObjectType, List<SObject>>();
        }
        for (SObject obj : sObjectsToInsert) {
            addToRelationList(obj, null, null, TypeOfDMLOperation.DML_Insert);
        }
    }

    public void addToInsert(SObject sObjectToInsert) {
        if (sObjectToInsert == null) {
            throw new UnitOfWorkException('SObject could not be null!');
        }
        if (toInsert == null) {
            toInsert = new Map<SObjectType, List<SObject>>();
        }
        addToRelationList(sObjectToInsert, null, null, TypeOfDMLOperation.DML_Insert);
    }

    public void addToInsert(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Child could not be null!');
        }
        if (toInsert == null) {
            toInsert = new Map<SObjectType, List<SObject>>();
        }
        addToRelationList(child, childFieldToParent, parent, TypeOfDMLOperation.DML_Insert);
    }

    public void addToUpdate(List<SObject> sObjectsToUpdate) {
        if (sObjectsToUpdate == null || sObjectsToUpdate.size() == 0) {
            throw new UnitOfWorkException('The list should be initialized and have at list one value!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }
        for (SObject obj : sObjectsToUpdate) {
            addToRelationList(obj, null, null, TypeOfDMLOperation.DML_Update);
        }
    }

    public void addToUpdate(SObject sObjectToUpdate) {
        if (sObjectToUpdate == null) {
            throw new UnitOfWorkException('SObject could not be null!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }
        addToRelationList(sObjectToUpdate, null, null, TypeOfDMLOperation.DML_Update);
    }

    public void addToUpdate(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Child could not be null!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }
        addToRelationList(child, childFieldToParent, parent, TypeOfDMLOperation.DML_Update);
    }

    public void addToUpsert(List<SObject> sObjectsToUpsert) {
        if (sObjectsToUpsert == null || sObjectsToUpsert.size() == 0) {
            throw new UnitOfWorkException('The list should be initialized and have at list one value!');
        }
        for (SObject sObj : sObjectsToUpsert) {
            if (sObj.Id == null) {
                addToInsert(sObj);
            } else {
                addToUpdate(sObj);
            }
        }
    }

    public void addToUpsert(SObject sObjectToUpsert) {
        if (sObjectToUpsert == null) {
            throw new UnitOfWorkException('SObject could not be null!');
        }
        if (sObjectToUpsert.Id == null) {
            addToInsert(sObjectToUpsert);
        } else {
            addToUpdate(sObjectToUpsert);
        }
    }

    public void addToUpsert(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Child could not be null!');
        }
        if (child.Id == null) {
            addToInsert(child, childFieldToParent, parent);
        } else {
            addToUpdate(child, childFieldToParent, parent);
        }
    }

    public void addToDelete(List<SObject> sObjectsToDelete) {
        if (sObjectsToDelete == null || sObjectsToDelete.size() == 0) {
            throw new UnitOfWorkException('The list should be initialized and have at list one value!');
        }
        if (toDelete == null) {
            toDelete = new Map<SObjectType, List<SObject>>();
        }
        for (SObject obj : sObjectsToDelete) {
            addToRelationList(obj, null, null, TypeOfDMLOperation.DML_Delete);
        }
    }

    public void addToDelete(SObject sObjectToDelete) {
        if (sObjectToDelete == null) {
            throw new UnitOfWorkException('SObject could not be null!');
        }
        if (toDelete == null) {
            toDelete = new Map<SObjectType, List<SObject>>();
        }
        addToRelationList(sObjectToDelete, null, null, TypeOfDMLOperation.DML_Delete);
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

    private void addToDeleteMap(SObject child) {
        if (!toDelete.containsKey(child.getSObjectType())) {
            toDelete.put(child.getSObjectType(), new List<SObject>());
        }
        toDelete.get(child.getSObjectType()).add(child);
    }

    public void registerRelations(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Child could not be null!');
        }
        addToRelationList(child, childFieldToParent, parent, null);
    }

    private void addToRelationList(SObject child,
            SObjectField childFieldToParent, SObject parent, TypeOfDMLOperation operation) {
        isTypeNotMentioned(child);
        switch on operation {
            when DML_Insert {
                addToInsertMap(child);
            }
            when DML_Update {
                addToUpdateMap(child);
            }
            when DML_Delete {
                addToDeleteMap(child);
            }
        }
        if (childFieldToParent != null && parent != null) {
            if (relationsToUpsert == null) {
                relationsToUpsert = new List<UnitOfWork.Relation>();
            }
            relationsToUpsert.add(new Relation(child, childFieldToParent, parent));
        }
    }

    @TestVisible
    private void isTypeNotMentioned(SObject obj) {
        if (!sObjectTypesToWorkWithDatabase.contains(obj.getSObjectType())) {
            throw new UnitOfWorkException('SObjectType has not been mentioned!');
        }
    }

    public void commitWork() {
        for (SObjectType sObjectType : sObjectTypesToWorkWithDatabase) {
            if (toInsert != null && toInsert.get(sObjectType) != null) {
                tryToLoad(toInsert.get(sObjectType), TypeOfDMLOperation.DML_Insert);
            }
            if (toUpdate != null && toUpdate.get(sObjectType) != null) {
                tryToLoad(toUpdate.get(sObjectType), TypeOfDMLOperation.DML_Update);
            }
            if (toDelete != null && toDelete.get(sObjectType) != null) {
                tryToLoad(toDelete.get(sObjectType), TypeOfDMLOperation.DML_Delete);
            }
        }

        if (relationsToUpsert != null) {
            if (childrenWithRelationsToUpdate == null) {
                childrenWithRelationsToUpdate = new List<SObject>();
            }
            for (Relation relation : relationsToUpsert) {
                childrenWithRelationsToUpdate.add(relation.addChildObjectWithField());
            }
            tryToLoad(childrenWithRelationsToUpdate, TypeOfDMLOperation.DML_Update);
        }
    }

    private void tryToLoad(List<SObject> sObjects, TypeOfDMLOperation operation) {
        Savepoint savepoint = Database.setSavepoint();
        try {
            switch on operation {
                when DML_Insert {
                    insert sObjects;
                }
                when DML_Update {
                    update sObjects;
                }
                when DML_Delete {
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
            if (isFieldNotCorrect(child, childFieldToParent, parent)) {
                throw new UnitOfWorkException('Wrong child field!');
            }
            this.child = child;
            this.childFieldToParent = childFieldToParent;
            this.parent = parent;
        }

        private Boolean isFieldNotCorrect(SObject child, SObjectField childFieldToParent, SObject parent) {
            return !child.getSObjectType().getDescribe().fields.getMap().values().contains(childFieldToParent)
                    && !childFieldToParent.getDescribe().referenceTo.contains(parent.getSObjectType());
        }

        SObject addChildObjectWithField() {
            child.put(childFieldToParent, parent.Id);
            return child;
        }
    }

    @TestVisible
    private class UnitOfWorkException extends Exception {
    }
}