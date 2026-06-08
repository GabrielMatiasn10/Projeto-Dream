import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getDadosConta from '@salesforce/apex/AgenteCheckInPainelControle.getDadosConta';
import getCheckInsAbertos from '@salesforce/apex/AgenteCheckInPainelControle.getCheckInsAbertos';
import getContaIdDoCheckIn from '@salesforce/apex/AgenteCheckInPainelControle.getContaIdDoCheckIn';

export default class AgenteCheckInPainel extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track conta;
    @track checkIns = [];
    @track errorMessage;
    @track isLoading = true;
    @track resolvedContaId;

    @wire(CurrentPageReference)
    pageRef(ref) {
        if (ref && ref.attributes && ref.attributes.recordId) {
            const id = ref.attributes.recordId;
            if (id && id.startsWith('a0')) {
                getContaIdDoCheckIn({ checkInId: id })
                    .then(contaId => {
                        this.resolvedContaId = contaId;
                    })
                    .catch(() => {
                        this.errorMessage = 'Erro ao carregar dados do cliente.';
                        this.isLoading = false;
                    });
            } else {
                this.resolvedContaId = id;
            }
        } else if (this.recordId) {
            // Fallback — usa o @api recordId diretamente
            this.resolvedContaId = this.recordId;
        }
    }

    // Fallback adicional via connectedCallback
    connectedCallback() {
        if (!this.resolvedContaId && this.recordId) {
            this.resolvedContaId = this.recordId;
        }
    }

    @wire(getDadosConta, { contaId: '$resolvedContaId' })
    wiredConta({ data, error }) {
        if (data) {
            this.conta = data;
            this.isLoading = false;
            this.errorMessage = undefined;
        } else if (error) {
            this.errorMessage = 'Erro ao carregar dados do cliente.';
            this.isLoading = false;
        }
    }

    @wire(getCheckInsAbertos, { contaId: '$resolvedContaId' })
    wiredCheckIns({ data, error }) {
        if (data) {
            this.checkIns = data;
            this.errorMessage = undefined;
        } else if (error) {
            this.errorMessage = 'Erro ao carregar check-ins.';
            this.checkIns = [];
        }
    }

    get proximoVoo() {
        return this.checkIns && this.checkIns.length > 0
            ? this.checkIns[0]
            : null;
    }

    get outrosCheckIns() {
        return this.checkIns && this.checkIns.length > 1
            ? this.checkIns.slice(1)
            : null;
    }

    get showContent() {
        return this.conta && !this.errorMessage && !this.isLoading;
    }

    get hasError() {
        return !!this.errorMessage;
    }

    get semCheckIns() {
        return this.checkIns && this.checkIns.length === 0 && !this.errorMessage;
    }

    handleNovoCheckIn() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Check_In__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: `Cliente__c=${this.resolvedContaId}`
            }
        });
    }
}