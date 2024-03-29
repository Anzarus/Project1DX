/**
 * Created by AntonAntoniuk on 20.10.2019.
 */

import {LightningElement, wire, track, api} from 'lwc';
import getItems from '@salesforce/apex/ItemManagementComponentController.getItems';

export default class ItemManagementComponent extends LightningElement {

    numberOfItemsOnPage = 10;
    totalCountOfPages;
    itemsByIds;

    @api recordId;

    @track items;
    @track error;
    @track currentPage = 1;
    @track currentItem;

    @wire(getItems, {recordId: '$recordId'}) wiredItems({error, data}) {//todo wrong послідовність
        if (data) {
            this.items = data;
            this.error = undefined;
            this.totalCountOfPages = this.numberOfPages();
        } else if (error) {
            this.error = error;
            this.items = undefined;
        }
    }

    get listOfItemsForThisPage() {
        if (this.items !== undefined) {
            const firstItemIteratorOnPage = this.numberOfItemsOnPage * (this.currentPage - 1);
            const resultList = [];
            for (let i = firstItemIteratorOnPage; i < firstItemIteratorOnPage + 10; i++) {
                if (i === this.items.length) break;
                resultList.push(this.items[i]);
            }
            return resultList;
        }
    }

    numberOfPages() {
        return Math.ceil(this.items.length / this.numberOfItemsOnPage);
    }

    handleFirst() {
        this.currentPage = 1;
    }

    handlePrevious() {
        this.currentPage = this.currentPage - 1;
    }

    handleNext() {
        this.currentPage = this.currentPage + 1;
    }

    handleLast() {
        this.currentPage = this.totalCountOfPages;
    }

    handleItemEvent(itemevt) {
        if (this.itemsByIds === undefined) {
            this.itemsByIds = new Map();
            for (let i = 0; i < this.items.length; i++) {
                this.itemsByIds.set(this.items[i].Id, this.items[i]);
            }
        }
        this.currentItem = this.itemsByIds.get(itemevt.detail);
    }
}