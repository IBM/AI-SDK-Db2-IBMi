------
-- Ensure authenticate can return Y (success)
------

call dbsdk_v1.logoutjob();
call dbsdk_v1.wx_setapikeyforjob('');
call dbsdk_v1.wx_setprojectidforjob('');

-- Should return Y
values dbsdk_v1.ShouldGetNewToken();

-- Should return Y
values dbsdk_v1.authenticate();

-- Should return N
values dbsdk_v1.ShouldGetNewToken();

values dbsdk_v1.generate('Hello world');
values dbsdk_v1.generate('Hello world', model_id => 'meta-llama/llama-2-13b-chat');

------
-- Ensure authenticate can return N (failed)
------

call dbsdk_v1.logoutjob();
call dbsdk_v1.wx_setapikeyforjob('-BAD');

-- Should return Y
values dbsdk_v1.ShouldGetNewToken();

-- Should return N
values dbsdk_v1.authenticate();

-- Should return Y
values dbsdk_v1.ShouldGetNewToken();

-- Should return '*PLSAUTH'
values dbsdk_v1.generate('Hello world');

------
-- Validate URL
------

-- Should return 'https://us-south.ml.cloud.ibm.com/ml/v1/text/generation?version=2023-07-07'
values dbsdk_v1.geturl('/text/generation');

------
-- Gets a list of models
------

call dbsdk_v1.getmodels();

------
-- Test parameters function
------

values dbsdk_v1.parameters(temperature => 0.5, time_limit => 1000);

-- Should return {"temperature":0.5,"time_limit":1000}