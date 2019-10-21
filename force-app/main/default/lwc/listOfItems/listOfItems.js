/**
 * Created by AntonAntoniuk on 18.10.2019.
 */

import {LightningElement, api} from 'lwc';

export default class ListOfItems extends LightningElement {

    @api itemsForThisPage;

    get itemsUndefined() {
        this.itemsForThisPage === undefined;
    }

    handleSelectedEvent(event){
        const itemevt = new CustomEvent(
            'itemevt', {detail : event.detail}
        );

        this.dispatchEvent(itemevt);
    }
}