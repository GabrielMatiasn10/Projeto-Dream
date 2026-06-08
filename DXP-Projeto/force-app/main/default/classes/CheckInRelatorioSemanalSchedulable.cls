global class CheckInRelatorioSemanalSchedulable implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        enviarRelatorio();
    }
    
    public void enviarRelatorio() {
        
        List<Check_In__c> checkInsAbertos = [
            SELECT Id, Name, CreatedDate, Owner.Name 
            FROM Check_In__c 
            WHERE Status__c = 'Novo' 
            LIMIT 1000
        ];
        
        if (checkInsAbertos.isEmpty()) {
            System.debug('Nenhum check-in novo/aberto encontrado.');
            return; 
        }
        
        String htmlBody = '<h2>Relatório Semanal de Check-ins em Aberto</h2>';
        htmlBody += '<p>Olá, seguem os check-ins que ainda estão com status Novo:</p>';
        htmlBody += '<table border="1" style="border-collapse: collapse; width: 100%;">';
        htmlBody += '<tr style="background-color: #f2f2f2;"><th>Nome/Id</th><th>Data de Criação</th><th>Responsável</th></tr>';
        
        for (Check_In__c c : checkInsAbertos) {
            htmlBody += '<tr>';
            htmlBody += '  <td style="padding: 8px;">' + c.Name + '</td>';
            htmlBody += '  <td style="padding: 8px;">' + c.CreatedDate.format('dd/MM/yyyy') + '</td>';
            htmlBody += '  <td style="padding: 8px;">' + c.Owner.Name + '</td>';
            htmlBody += '</tr>';
        }
        htmlBody += '</table>';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {
            'gm4037003@gmail.com',
            'guilherme58827@gmail.com'
        }; 
        mail.setToAddresses(toAddresses);
        
        mail.setSubject(' Relatório Semanal: Check-ins em Aberto');
        mail.setHtmlBody(htmlBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}