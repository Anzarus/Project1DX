/**
 * Created by AntonAntoniuk on 07.10.2019.
 */

public with sharing class UnitOfWork {
    private Set<SObjectType> sObjectTypesToWorkWithDatabase;

    private Map<SObjectType, List<SObject>> toInsert;
    private Map<SObjectType, List<SObject>> toUpdate;
    private Map<SObjectType, List<SObject>> toDelete;

    private List<Relation> relationsToUpsert;
    private Map<SObjectType, List<Relation>> relationsToInsertWithSObject;
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
            addToSObjectToCorrectList(obj, null, null, TypeOfDMLOperation.DML_Insert);
        }
    }

    public void addToInsert(SObject sObjectToInsert) {
        if (sObjectToInsert == null) {
            throw new UnitOfWorkException('SObject could not be null!');
        }
        if (toInsert == null) {
            toInsert = new Map<SObjectType, List<SObject>>();
        }
        addToSObjectToCorrectList(sObjectToInsert, null, null, TypeOfDMLOperation.DML_Insert);
    }

    public void addToInsert(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Child could not be null!');
        }
        if (toInsert == null) {
            toInsert = new Map<SObjectType, List<SObject>>();
        }
        addToSObjectToCorrectList(child, childFieldToParent, parent, TypeOfDMLOperation.DML_Insert);
    }

    public void addToUpdate(List<SObject> sObjectsToUpdate) {
        if (sObjectsToUpdate == null || sObjectsToUpdate.size() == 0) {
            throw new UnitOfWorkException('The list should be initialized and have at list one value!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }
        for (SObject obj : sObjectsToUpdate) {
            addToSObjectToCorrectList(obj, null, null, TypeOfDMLOperation.DML_Update);
        }
    }

    public void addToUpdate(SObject sObjectToUpdate) {
        if (sObjectToUpdate == null) {
            throw new UnitOfWorkException('SObject could not be null!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }
        addToSObjectToCorrectList(sObjectToUpdate, null, null, TypeOfDMLOperation.DML_Update);
    }

    public void addToUpdate(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (child == null) {
            throw new UnitOfWorkException('Child could not be null!');
        }
        if (toUpdate == null) {
            toUpdate = new Map<SObjectType, List<SObject>>();
        }
        addToSObjectToCorrectList(child, childFieldToParent, parent, TypeOfDMLOperation.DML_Update);
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
            addToSObjectToCorrectList(obj, null, null, TypeOfDMLOperation.DML_Delete);
        }
    }

    public void addToDelete(SObject sObjectToDelete) {
        if (sObjectToDelete == null) {
            throw new UnitOfWorkException('SObject could not be null!');
        }
        if (toDelete == null) {
            toDelete = new Map<SObjectType, List<SObject>>();
        }
        addToSObjectToCorrectList(sObjectToDelete, null, null, TypeOfDMLOperation.DML_Delete);
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
        addToSObjectToCorrectList(child, childFieldToParent, parent, null);
    }

    private void addToSObjectToCorrectList(SObject child, SObjectField childFieldToParent, SObject parent,
            TypeOfDMLOperation operation) {
        isTypeNotMentioned(child);
        if (childFieldToParent != null && parent != null) {
            if (operation == TypeOfDMLOperation.DML_Insert) {
                addRelationOnInsert(child, childFieldToParent, parent);
            } else {
                addRelationsToUpdate(child, childFieldToParent, parent);
            }
        } else {
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
        }
    }

    private void addRelationsToUpdate(SObject child, SObjectField childFieldToParent, SObject parent) {
        if (relationsToUpsert == null) {
            relationsToUpsert = new List<UnitOfWork.Relation>();
        }
        relationsToUpsert.add(new Relation(child, childFieldToParent, parent));
    }

    private void addRelationOnInsert(SObject child,
            SObjectField childFieldToParent, SObject parent) {
        if (relationsToInsertWithSObject == null) {
            relationsToInsertWithSObject = new Map<SObjectType, List<UnitOfWork.Relation>>();
        }
        if (!relationsToInsertWithSObject.containsKey(parent.getSObjectType())) {
            relationsToInsertWithSObject.put(parent.getSObjectType(), new List<Relation>());
        }
        relationsToInsertWithSObject.get(parent.getSObjectType()).add(new Relation(child, childFieldToParent, parent));
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
                setChildFieldsToInsert(sObjectType);
            }
            if (toUpdate != null && toUpdate.get(sObjectType) != null) {
                tryToLoad(toUpdate.get(sObjectType), TypeOfDMLOperation.DML_Update);
                setChildFieldsToInsert(sObjectType);
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

    private void setChildFieldsToInsert(SObjectType parentSObjectType) {
        if (relationsToInsertWithSObject != null
                && relationsToInsertWithSObject.containsKey(parentSObjectType)) {
            for (Relation relation : relationsToInsertWithSObject.get(parentSObjectType)) {
                addToInsert(relation.addChildObjectWithField());
            }
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