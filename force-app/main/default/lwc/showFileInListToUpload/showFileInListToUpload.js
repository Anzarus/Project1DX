/**
 * Created by AntonAntoniuk on 06.11.2019.
 */

import {LightningElement, api} from 'lwc';

export default class ShowFileInListToUpload extends LightningElement {

    @api file;

    handleFileUploadClick() {
        const file_evt = new CustomEvent(
            'file_event', {detail: this.file.Id}
        );
        this.dispatchEvent(file_evt);
    }
}