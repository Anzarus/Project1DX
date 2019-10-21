/**
 * Created by AntonAntoniuk on 21.10.2019.
 */

import {LightningElement, api} from 'lwc';

export default class PageControlButtons extends LightningElement {

    @api currentPage;
    @api totalCountOfPages;

    get showPreviousNext() {
        return this.totalCountOfPages > 1;
    }

    get showToFirst() {
        return this.currentPage !== 1 && this.totalCountOfPages > 2;
    }

    get showToLast() {
        return this.currentPage !== this.totalCountOfPages && this.totalCountOfPages > 2;
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
}