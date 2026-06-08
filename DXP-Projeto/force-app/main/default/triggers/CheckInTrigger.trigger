trigger CheckInTrigger on Check_In__c (after insert, after update) {
    
    CheckInHandler.atualizarContadores(Trigger.new);
}