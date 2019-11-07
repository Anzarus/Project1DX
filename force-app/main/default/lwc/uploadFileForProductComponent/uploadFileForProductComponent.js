/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

import {LightningElement, track, wire, api} from 'lwc';
import userId from '@salesforce/user/Id';
import getPersonalFilesForCurrentUser
    from '@salesforce/apex/UploadFileForProductController.getPersonalFilesForCurrentUser';
import sendFileToDropBoxViaOrg
    from '@salesforce/apex/UploadFileForProductController.sendFileToDropBoxViaOrg';
import sendFileToDropBox
    from '@salesforce/apex/UploadFileForProductController.sendFileToDropBox';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class UploadFileForProductComponent extends LightningElement {

    currentUserId = userId;
    cacheToOrg = false;
    MAX_FILE_SIZE = 1048576; //1 Mb

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
            {label: 'Upload from a local device', value: 'local'},
            {label: 'Upload from a local through org', value: 'localWithOrg'},
            {label: 'Upload from Org', value: 'org'}
        ];
    }

    get isUploadFromLocal() {
        return this.uploadVariant === 'local';
    }

    get isUploadFromLocalThroughOrg() {
        return this.uploadVariant === 'localWithOrg';
    }

    get isUploadFromOrg() {
        return this.uploadVariant === 'org';
    }

    changeVariant(event) {
        this.uploadVariant = event.target.value;
    }

    handleCacheCheckBox() {
        this.cacheToOrg = !this.cacheToOrg;
    }

    handleUploadFile(event) {
        let file;
        if (event.target.files.length === 1) {
            file = event.target.files[0];
        } else {
            this.showToastNotification(
                'Info',
                'You should choose a file to download!',
                'info'
            );
        }
        if (file.size > this.MAX_FILE_SIZE) {
            this.showToastNotification(
                'Error',
                'This file is too large, it must be less 1Mb!',
                'error');
            return;
        }

        let fileReader = new FileReader();

        fileReader.onloadend = (() => {
            let fileContent = fileReader.result;
            let base64 = 'base64,';

            fileContent = fileContent.substring(fileContent.indexOf(base64) + base64.length);
            sendFileToDropBox({fileId: file.name, content: fileContent, productId: this.recordId})
                .then(() => {
                    this.showToastNotification(
                        'Success',
                        'File has been upload!',
                        'success');
                })
                .catch(error => {
                    this.showToastNotification(
                        'Error',
                        error.statusText + '. ' + error.body.message + '!',
                        'error'
                    );
                });
        });

        fileReader.readAsDataURL(file);
    }

    handleFileEvent(item_event) {
        sendFileToDropBoxViaOrg({fileId: item_event.detail, productId: this.recordId, cacheToOrg: this.cacheToOrg})
            .then(() => {
                this.showToastNotification(
                    'Success',
                    'File has been upload!',
                    'success'
                );
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
        this.handleFileEvent(uploadedFile);
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