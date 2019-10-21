/**
 * Created by AntonAntoniuk on 18.10.2019.
 */

import {LightningElement, api} from 'lwc';

export default class ItemDetails extends LightningElement {

    @api currentItem;

    get correctColor() {
        if (this.currentItem.Status__c === 'Hot') {
            return 'custom-red-text';
        }
        if (this.currentItem.Status__c === 'Normal') {
            return 'custom-blue-text';
        }
    }

    get isCurrentItemUndefined(){
        return this.currentItem === undefined;
    }
}