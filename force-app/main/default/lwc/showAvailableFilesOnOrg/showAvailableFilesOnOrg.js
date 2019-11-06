/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

import {LightningElement, api} from 'lwc';

export default class ShowAvailableFilesOnOrg extends LightningElement {

    @api filesForCurrentUser;

    handleFileUploadClick(event) {
        console.log(event);
        console.log(event.target.parentElement.dataset.item);
        const file_evt = new CustomEvent(
            'file_event', {detail: event.detail}
        );

        this.dispatchEvent(file_evt);
    }
}