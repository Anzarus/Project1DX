/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

import {LightningElement, track, api, wire} from 'lwc';
import userId from '@salesforce/user/Id';
import getPersonalFilesForCurrentUser
    from '@salesforce/apex/UploadFileForProductController.getPersonalFilesForCurrentUser';
import sendFileToDropBox
    from '@salesforce/apex/UploadFileForProductController.sendFileToDropBox';

export default class UploadFileForProductComponent extends LightningElement {

    currentUserId = userId;

    @track currentUserFiles;
    @track error;
    @track uploadVariant = 'local';

    @wire(getPersonalFilesForCurrentUser, {currentUserId: '$currentUserId'}) wiredFiles({error, data}) {
        if (data) {
            this.currentUserFiles = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.currentUserFiles = undefined;
        }
    }

    handleUploadFinished(event) {
        console.log(event.detail.files);//todo call apex method to upload it to dropBox and delete from sf
    }

    get options() {
        return [
            {label: 'Upload from local device', value: 'local'},
            {label: 'Upload from Org', value: 'org'}//todo
        ];
    }

    get isUploadFromLocal() {
        return this.uploadVariant === 'local';
    }

    changeVariant(event) {
        this.uploadVariant = event.target.value;
    }

    // handleFileEvent(item_event) {
    //     console.log(item_event.detail.Id);
    //     sendFileToDropBox({fileId: item_event.detail.Id})
    //         .then(result => {
    //             todo show toast event if all ok
            // }).catch(error => {
            // this.error = error;
        // })
    // }
}