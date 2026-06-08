@IsTest
private class CheckInHandlerTest {
    private static Account criarConta() {
        Account conta = new Account(
            Name = 'Cliente Teste',
            CPF__c = '123.456.789-00',
            Email__c = 'teste@teste.com'
        );
        insert conta;
        return conta;
    }

    private static Check_In__c criarCheckIn(Id contaId, String status) {
        return new Check_In__c(
            Cliente__c = contaId,
            Status__c = status,
            Aeroporto_de_Check_In__c = 'REC',
            Aeroporto_de_Destino__c = 'GRU',
            Codigo_do_Voo__c = 'LA1234',
            Horario_do_Voo__c = DateTime.now().addHours(3),
            Numero_do_Assento__c = '12A'
        );
    }

    @IsTest
    static void testInsertAtualizaContadores() {
        Account conta = criarConta();
        Test.startTest();
        List<Check_In__c> checkIns = new List<Check_In__c>();
        for (Integer i = 0; i < 3; i++) {
            checkIns.add(criarCheckIn(conta.Id, 'Novo'));
        }
        insert checkIns;
        Test.stopTest();

        Account resultado = [
            SELECT Numero_de_Check_Ins_Totais__c, Numero_de_Check_Ins_no_Ano__c
            FROM Account WHERE Id = :conta.Id
        ];
        System.assertEquals(3, resultado.Numero_de_Check_Ins_Totais__c, 'Total deve ser 3');
        System.assertEquals(3, resultado.Numero_de_Check_Ins_no_Ano__c, 'Ano deve ser 3');
    }

    @IsTest
    static void testUpdateAtualizaContadores() {
        Account conta = criarConta();
        Check_In__c ci = criarCheckIn(conta.Id, 'Novo');
        insert ci;

        Test.startTest();
        ci.Status__c = 'Realizado';
        update ci;
        Test.stopTest();

        Account resultado = [
            SELECT Numero_de_Check_Ins_Totais__c
            FROM Account WHERE Id = :conta.Id
        ];
        System.assertEquals(1, resultado.Numero_de_Check_Ins_Totais__c, 'Total deve ser 1');
    }

    @IsTest
    static void testBulkInsert() {
        Account conta = criarConta();
        Test.startTest();
        List<Check_In__c> checkIns = new List<Check_In__c>();
        for (Integer i = 0; i < 200; i++) {
            checkIns.add(criarCheckIn(conta.Id, 'Novo'));
        }
        insert checkIns;
        Test.stopTest();

        Account resultado = [
            SELECT Numero_de_Check_Ins_Totais__c
            FROM Account WHERE Id = :conta.Id
        ];
        System.assertEquals(200, resultado.Numero_de_Check_Ins_Totais__c, 'Bulk deve funcionar');
    }
}