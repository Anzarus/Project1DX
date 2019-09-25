/**
 * Created by AntonAntoniuk on 25.09.2019.
 */

trigger HttpEventTrigger on Http_Event__e (after insert) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            new HttpEventTriggerHandler().setHttpRecords(Trigger.new);
        }
    }
}