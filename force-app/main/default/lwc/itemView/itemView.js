/**
 * Created by AntonAntoniuk on 18.10.2019.
 */

import {LightningElement, api} from 'lwc';

export default class ItemView extends LightningElement {

    @api item;

    get correctColor() {
        if (this.item.Status__c === 'Hot') {
            return 'custom-red-text';
        }
        if (this.item.Status__c === 'Normal') {
            return 'custom-blue-text';
        }
    }

    handleOnclick() {
        this.dispatchEvent(new CustomEvent('selected', {detail: this.item.Id}));
    }
}