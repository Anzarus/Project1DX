/**
 * Created by AntonAntoniuk on 20.10.2019.
 */

import {LightningElement, wire, track, api} from 'lwc';
import getItems from '@salesforce/apex/ItemManagementComponentController.getItems';

export default class ItemManagementComponent extends LightningElement {

    @api recordId;

    @track items;
    @track error;

    @wire(getItems, {recordId: '$recordId'}) wiredItems({error, data}) {//todo wrong послідовність
        if (data) {
            this.items = data;
            this.error = undefined;
            console.log('success');
            console.log(this.items);
            // this.totalCountOfPages = this.numberOfPages();
        } else if (error) {
            this.error = error;
            this.items = undefined;
        }
    }

    numberOfItemsOnPage = 10;
    // totalCountOfPages;
    currentPage = 1;

    get listOfItemsForThisPage() {
        console.log('items');
        console.log(this.items);
        console.log('items.size');
        console.log(this.items.size);
        const firstItemIteratorOnPage = this.numberOfItemsOnPage * this.currentPage - 1;
        const resultList = [];
        for (let i = firstItemIteratorOnPage; i < firstItemIteratorOnPage + 10; i++) {
            resultList.push(this.items[i]);
        }
        return resultList;
    }

    // numberOfPages() {
    //     return Math.ceil(this.items.size / this.numberOfItemsOnPage);
    // }

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
        this.currentPage = this.items.size - 1;
    }
}