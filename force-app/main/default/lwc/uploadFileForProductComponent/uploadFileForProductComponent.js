/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

import {LightningElement, track, api} from 'lwc';

export default class UploadFileForProductComponent extends LightningElement {

    @track uploadVariant = true;

    @api userRecordId = '0053E000003p8c0QAA';//todo get currentUser

    handleUploadFinished(event) {
        console.log(event.detail.files);//todo call apex method to upload it to dropBox and delete from sf
    }

    get options() {
        console.log('1');
        return [
            {label: 'Upload from local device', value: 'local'},
            {label: 'Upload from Org', value: 'org'}//todo
        ];
    }

    get isUploadFromLocal() {
        return this.uploadVariant;
    }

    get changeVariant() {
        return this.uploadVariant;
    }
}