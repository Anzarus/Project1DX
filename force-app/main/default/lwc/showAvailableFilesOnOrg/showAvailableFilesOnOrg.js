/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

import {LightningElement, api} from 'lwc';

export default class ShowAvailableFilesOnOrg extends LightningElement {

    @api filesForCurrentUser;

    handleUploadClick(file_event) {
        const list_of_files_evt = new CustomEvent(
            'list_of_files_evt', {detail: file_event.detail}
        );
        this.dispatchEvent(list_of_files_evt);
    }
}