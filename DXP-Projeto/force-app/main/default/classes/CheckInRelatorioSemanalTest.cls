@isTest
private class CheckInRelatorioSemanalTest {

    @isTest
    static void testAgendamentoEEnvio() {
        // 1. Criar conta obrigatória para o teste
        Account conta = new Account(Name = 'Conta Teste Relatorio', CPF__c = '000.000.000-00');
        insert conta;

        // 2. Criar o Check_In__c associado à conta com status 'Novo'
        Check_In__c novoCheckIn = new Check_In__c(
            Cliente__c = conta.Id,
            Status__c = 'Novo',
            Aeroporto_de_Check_In__c = 'REC',
            Aeroporto_de_Destino__c = 'GRU',
            Codigo_do_Voo__c = 'LA1234',
            Horario_do_Voo__c = DateTime.now().addHours(3),
            Numero_do_Assento__c = '12A'
        );
        insert novoCheckIn;
        
        String CRON_EXP = '0 0 0 ? * SUN';
        
        Test.startTest();
        String jobId = System.schedule('TesteRelatorioSemanal', CRON_EXP, new CheckInRelatorioSemanalSchedulable());
        Test.stopTest();
        
        System.assert(jobId != null, 'O agendamento deveria ter sido gerado.');
    }
}