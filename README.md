-------------------- !!!! PLEASE DONT FORGET TO ADD YOUR ACCESS KEYS IN provider.tf FILE !!!! --------------------------------------------


## EVERYTHING IN TERRAFORM FILES NO SCREENSHOTS TO ADD 

## TERRAFOM INIT && TERRAFORM AAPLY -- IN ORDER TO RUN THE PROJECT ON YOUR AWS ACCOUNT 

## RESPECT THE BODY PARAMS  FORMAT WHEN SENDING REQUEST TO ENDPOINTS 
    --  Endpoint : POST https://tz7ichx27b.execute-api.eu-west-3.amazonaws.com/prod/addToDynamo  
    --  No access tokens NEEDED in HEADER
    --  {
            "id":"new11112",
            "content":"TESTINGLAMBVDAdsqdqsdsq11",
            "jobType": "addToS3"
        }
    -- VERIFY BODY TYPE TO JSON PLEASE
    -- NOTE THAT ENDPOINT URL DEPENDS ON OUR REGION AND TERRAFOM CONFIGS PLEASE VERIFY BEFORE USING , SHOULD LOOK SMTH LIKE THE URL LISTED ABOVVE
## PLEASE VERIFY CLOUDWATCH LOGS FOR ANY ERRORS IF SOMETHING IS NOT WORKING CORRECTLY   
## YOU CAN VERIFY LAMBDA BEING TRIGGERED IN ARS CLOUDWATCH LOGS 

## IMAGE 
![alt text](https://github.com/feyez123456/aws_project_dsp/blob/fac685ba1b4dc2cf908be2a87317fcc9f305a63d/apiLambdaVersion/image.png)
## CONTRIBUTERS :  (DSP ARCHI)
    -- BEHI Feyez
    -- BIROUK aymane 
    -- SUSTAC andré 
