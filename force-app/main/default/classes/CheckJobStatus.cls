/**
 * Created by AntonAntoniuk on 20.09.2019.
 */

public with sharing class CheckJobStatus implements Schedulable {

    public void execute(SchedulableContext param1) {
        System.enqueueJob(new DropBoxCheckRemoveStatusJob());
    }
}