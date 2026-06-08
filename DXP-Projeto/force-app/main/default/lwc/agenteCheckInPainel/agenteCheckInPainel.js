import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getDadosConta from '@salesforce/apex/AgenteCheckInPainelControle.getDadosConta';
import getCheckInsAbertos from '@salesforce/apex/AgenteCheckInPainelControle.getCheckInsAbertos';
import getContaIdDoCheckIn from '@salesforce/apex/AgenteCheckInPainelControle.getContaIdDoCheckIn';

export default class AgentCheckInPanel extends NavigationMixin(LightningElement) {
    
    @api recordId;          // ID injetado automaticamente pela página
    @track conta;           // Dados da conta
    @track checkIns = [];   // Lista de check-ins abertos
    @track errorMessage;    // Mensagem de erro se algo falhar
    @track isLoading = true; // Controla o spinner
    @track resolvedContaId; // ID da conta resolvido

    // Resolve o ID da conta dependendo de onde o componente está
    @wire(CurrentPageReference)
pageRef(ref) {
    if (ref && ref.attributes && ref.attributes.recordId) {
        const id = ref.attributes.recordId;
        // Verifica se é um ID de Check-In (começa com o prefixo do objeto)
        if (id && id.startsWith('a0')) {
            // É um Check-In — busca o ID da conta
            getContaIdDoCheckIn({ checkInId: id })
                .then(contaId => {
                    this.resolvedContaId = contaId;
                })
                .catch(() => {
                    this.errorMessage = 'Erro ao carregar dados do cliente.';
                    this.isLoading = false;
                });
        } else {
            // É uma Conta — usa diretamente
            this.resolvedContaId = id;
        }
    }
}

    // Busca dados da conta via @wire reativo
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

    // Busca check-ins abertos via @wire reativo
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

    // Getter — primeiro check-in da lista é o próximo voo
    get proximoVoo() {
        return this.checkIns && this.checkIns.length > 0
            ? this.checkIns[0]
            : null;
    }

    // Getter — restante dos check-ins sem o primeiro
    get outrosCheckIns() {
        return this.checkIns && this.checkIns.length > 1
            ? this.checkIns.slice(1)
            : null;
    }

    // Getters de controle de visibilidade
    get showContent() {
        return this.conta && !this.errorMessage && !this.isLoading;
    }

    get hasError() {
        return !!this.errorMessage;
    }

    get semCheckIns() {
        return this.checkIns && this.checkIns.length === 0 && !this.errorMessage;
    }

    // Botão novo check-in — abre formulário de criação
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