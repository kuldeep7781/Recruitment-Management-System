import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getCandidates from '@salesforce/apex/CandidateDashboardController.getCandidates';
import searchCandidates from '@salesforce/apex/CandidateDashboardController.searchCandidates';

export default class CandidateDashboard extends LightningElement {

    
    // Properties
    @track candidates = [];
    @track error;
    @track isLoading = true;

    searchKey = '';

    // Stores wired response for refreshApex
    wiredResult;

    
    // Wire Apex Method
    @wire(getCandidates)
    wiredCandidates(result) {

        this.wiredResult = result;

        const { data, error } = result;

        this.isLoading = false;

        if (data) {
            this.candidates = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.candidates = [];
        }
    }

    
    // Search Input
    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    async handleSearch() {

        // If search box is empty, reload all candidates
        if (!this.searchKey || this.searchKey.trim() === '') {
            this.handleClearSearch();
            return;
        }

        this.isLoading = true;

        try {

            const result = await searchCandidates({
                keyword: this.searchKey
            });

            this.candidates = result;
            this.error = undefined;

        } catch (error) {

            this.error = error;
            this.candidates = [];

        } finally {

            this.isLoading = false;

        }
    }

    
    // Clear Search
    handleClearSearch() {

        this.searchKey = '';
        this.error = undefined;
        this.isLoading = true;

        refreshApex(this.wiredResult)
            .finally(() => {
                this.isLoading = false;
            });

    }

    
    // Getters
    get hasCandidates() {
        return this.candidates && this.candidates.length > 0;
    }

    get candidateCount() {
        return this.candidates ? this.candidates.length : 0;
    }

    get showEmptyState() {
        return !this.isLoading && this.candidates.length === 0;
    }

}