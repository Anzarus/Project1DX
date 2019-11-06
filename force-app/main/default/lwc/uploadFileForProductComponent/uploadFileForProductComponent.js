/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

import {LightningElement, track, wire, api} from 'lwc';
import userId from '@salesforce/user/Id';
import getPersonalFilesForCurrentUser
    from '@salesforce/apex/UploadFileForProductController.getPersonalFilesForCurrentUser';
import sendFileToDropBox
    from '@salesforce/apex/UploadFileForProductController.sendFileToDropBox';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class UploadFileForProductComponent extends LightningElement {

    currentUserId = userId;
    cacheToOrg = false;

    @api recordId;

    @track currentUserFiles;
    @track uploadVariant = 'local';

    @wire(getPersonalFilesForCurrentUser, {currentUserId: '$currentUserId'}) wiredFiles({error, data}) {
        if (data) {
            this.currentUserFiles = data;
        } else if (error) {
            this.showToastNotification(
                'Error',
                error.statusText + '. ' + error.body.message + '!',
                'error'
            );
        }
    }

    get options() {
        return [
            {label: 'Upload from local device', value: 'local'},
            {label: 'Upload from Org', value: 'org'}
        ];
    }

    get isUploadFromLocal() {
        return this.uploadVariant === 'local';
    }

    changeVariant(event) {
        this.uploadVariant = event.target.value;
    }

    handleCacheCheckBox() {
        this.cacheToOrg = !this.cacheToOrg;
    }

    handleFileEvent(item_event) {
        sendFileToDropBox({fileId: item_event.detail, productId: this.recordId, cacheToOrg: this.cacheToOrg})
            .then(result => {
                this.showToastNotification('Success', 'File has been upload!', 'success');
            }).catch(error => {
            this.showToastNotification(
                'Error',
                error.statusText + '. ' + error.body.message + '!',
                'error'
            );
        })
    }

    handleUploadFinished(event) {
        const uploadedFile = new Object({detail: event.detail.files[0].documentId});
        this.handleFileEvent(uploadedFile);//todo to delete or not to delete
    }

    showToastNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}