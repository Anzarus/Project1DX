/**
 * Created by AntonAntoniuk on 20.10.2019.
 */

import {LightningElement, wire, track, api} from 'lwc';
import getItems from '@salesforce/apex/ItemManagementComponentController.getItems';

export default class ItemManagementComponent extends LightningElement {

    numberOfItemsOnPage = 10;
    totalCountOfPages;
    currentPage = 1;

    @api recordId;

    @track items;
    @track error;

    @wire(getItems, {recordId: '$recordId'}) wiredItems({error, data}) {//todo wrong послідовність
        if (data) {
            this.items = data;
            this.error = undefined;
            console.log('success');
            console.log(this.items);
            this.totalCountOfPages = this.numberOfPages();
            console.log(this.items.length);
            console.log(this.totalCountOfPages)
        } else if (error) {
            this.error = error;
            this.items = undefined;
        }
    }

    get listOfItemsForThisPage() {
        console.log('render');
        if (this.items !== undefined) {
            const firstItemIteratorOnPage = this.numberOfItemsOnPage * (this.currentPage - 1);
            const resultList = [];
            for (let i = firstItemIteratorOnPage; i < firstItemIteratorOnPage + 10; i++) {
                if (i === this.items.length) break;
                resultList.push(this.items[i]);
                console.log(i);
            }
            console.log(resultList);
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
        this.currentPage = this.items.length - 1;
    }
}