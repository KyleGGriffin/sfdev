@RestResource(urlMapping = '/v1/Merge/*')

global with sharing class CC_MRNMerge_v1 {

    @HttpPost
    global static MRNResponseWrapper MergeMRN(){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; // Get the response object

        Blob body = req.requestBody;
        String requestJSON = body.toString();

        MRNRequestWrapper request;
        MRNResponseWrapper response = new MRNResponseWrapper();

        try {
            res.statusCode = 200;
            request = (MRNRequestWrapper) System.JSON.deserialize(requestJSON, MRNRequestWrapper.class);
        } catch (Exception ex) {
            res.statusCode = 400;
            
            MRNErrorWrapper error = new MRNErrorWrapper();
            error.msg = 'JSON_REQUEST_DESERIALIZATION_ERROR';
            response.error = error;
        }
        
        Merge_Log__c ml = new Merge_Log__c();
        ml.Inbound_JSON__c = requestJSON;
        ml.Response_Code__c = String.valueOf(res.StatusCode);
        
        if (request != null){
            ml.Non_surviving_MRN__c = request.nonSurvivingMRN;
            ml.Surviving_MRN__c = request.survivingMRN;
            ml.Event_Operation__c = request.eventOperation;
            ml.Operator_ID__c = request.operatorId;
        
        
            if (request.eventDateTime != null){
                ml.Merge_Date_Time__c = DateTime.valueOf(request.eventDateTime);
            }

        }
        
        
        insert ml;

        response.msg = 'inserted log';
        response.logID = ml.Id;
        
        return response;
        
        /*
        1. After you insert a log, it will attempt to find Non-surviving MRN and the surviving MRN. 
        2. Updating those according records
        3. Marking the non-surviving with a prefix
        4. Transfering related records to the surviving MRN.
        */
        
    }


    global class MRNRequestWrapper {
        public String nonSurvivingMRN;
        public String survivingMRN;
        public String eventDateTime;
        public String eventOperation;
        public String operatorId;
    }
    
    global class MRNResponseWrapper {
        public String msg;
        public String logID;
        public MRNErrorWrapper error;
    }

    global class MRNErrorWrapper {
        public String msg;
    }

}