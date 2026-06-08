public with sharing class AgenteCheckInPainelControle{
    // Buscar dados da conta.
    @AuraEnabled(cacheable=true)
    public static Account getDadosConta(Id contaId){
        return [
            SELECT Id, Name, CPF__c, 
                   Necessita_Cuidados_Especiais__c,
                   Numero_de_Check_Ins_no_Ano__c,
                   Numero_de_Check_Ins_Totais__c
            FROM Account
            WHERE Id = :contaId
            LIMIT 1
        ];
    }

    // Buscar Checkins em aberto.
    @AuraEnabled(cacheable=true)
    public static List<Check_In__c> getCheckInsAbertos(Id contaId){
        return [
            SELECT Id, Name, Status__c,
                   Aeroporto_de_Check_In__c,
                   Aeroporto_de_Destino__c,
                   Codigo_do_Voo__c,
                   Horario_do_Voo__c,
                   Numero_do_Assento__c
            FROM Check_In__c WHERE Cliente__c = :contaId
            AND Status__c IN ('Novo','Em Andamento')
            ORDER BY Horario_do_Voo__c ASC LIMIT 10
                   
        ];
        


    }

    // Pegar o Id da conta a partir do CheckIn.
    @AuraEnabled(cacheable=true)
    public static Id getContaIdDoCheckIn(Id checkInId){
        Check_In__c c = [
            SELECT Cliente__c
            FROM Check_In__c
            WHERE Id = :checkInId
            LIMIT 1
         ];
         return c.Cliente__c;

    }

    

}