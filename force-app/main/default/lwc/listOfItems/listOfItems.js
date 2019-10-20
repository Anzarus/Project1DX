/**
 * Created by AntonAntoniuk on 18.10.2019.
 */

import {LightningElement, api} from 'lwc';

export default class ListOfItems extends LightningElement {

    @api itemsForThisPage;

    get isNotFirstPage() {
        return this.currentPage !== 1;
    }

    get isNotLastPage() {
        return this.currentPage !== this.totalCountOfPages;
    }

    handleFirstPage() {
        this.dispatchEvent(new CustomEvent('first'))
    }

    handlePreviousPage() {
        this.dispatchEvent(new CustomEvent('previous'))
    }

    handleNextPage() {
        this.dispatchEvent(new CustomEvent('next'))
    }

    handleLastPage() {
        this.dispatchEvent(new CustomEvent('last'))
    }

    //todo add event to show details of items
}