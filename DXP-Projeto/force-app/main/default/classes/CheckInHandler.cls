public with sharing class CheckInHandler {
    // Perfeito! Tiramos o parâmetro antigo que não estava em uso
    public static void atualizarContadores(List<Check_In__c> novos) {
        // Coletar id das contas.
        Set<Id> contaIds = new Set<Id>();
        for (Check_In__c c : novos) {
            if (c.Cliente__c != null) {
                contaIds.add(c.Cliente__c);
            }
        }
        if (contaIds.isEmpty()) return; // saída antecipada.

        // Ano atual.
        Integer anoAtual = Date.today().year();
        Date inicioAno = Date.newInstance(anoAtual, 1, 1);
        Date fimAno = Date.newInstance(anoAtual, 12, 31);

        // Total por conta.
        Map<Id, Integer> totalMap = new Map<Id, Integer>();
        // CORREÇÃO: Adicionado o alias "contaId" no SELECT
        for (AggregateResult ar : [ 
            SELECT Cliente__c contaId, COUNT(Id) total 
            FROM Check_In__c 
            WHERE Cliente__c IN :contaIds 
            GROUP BY Cliente__c
        ]) {
            totalMap.put((Id) ar.get('contaId'), (Integer) ar.get('total'));
        }

        // Contagem de ano por conta.
        Map<Id, Integer> anoMap = new Map<Id, Integer>();
        // CORREÇÃO: Adicionado o alias "contaId" no SELECT
        for (AggregateResult ar : [ 
            SELECT Cliente__c contaId, COUNT(Id) total 
            FROM Check_In__c 
            WHERE Cliente__c IN :contaIds 
            AND CreatedDate >= :DateTime.newInstance(inicioAno, Time.newInstance(0,0,0,0)) 
            AND CreatedDate <= :DateTime.newInstance(fimAno, Time.newInstance(23,59,59,0)) 
            GROUP BY Cliente__c
        ]) {
            anoMap.put((Id) ar.get('contaId'), (Integer) ar.get('total'));
        }
        
        // Lista de contas para atualizar.
        List<Account> contasParaAtualizar = new List<Account>();
        for (Id contaId : contaIds) {
            Account conta = new Account(Id = contaId);
            
            // Atribuir numero de check-ins totais. (Ajustado para totalMap)
            if (totalMap.containsKey(contaId)) {
                conta.Numero_de_Check_Ins_Totais__c = totalMap.get(contaId);
            } else {
                conta.Numero_de_Check_Ins_Totais__c = 0;
            }

            // Atribuir numero de check-ins no ano.
            if (anoMap.containsKey(contaId)) {
                conta.Numero_de_Check_Ins_no_Ano__c = anoMap.get(contaId);
            } else {
                conta.Numero_de_Check_Ins_no_Ano__c = 0;
            }

            contasParaAtualizar.add(conta);
        }
        
        if (!contasParaAtualizar.isEmpty()) {
            update contasParaAtualizar;
        }
    }
}