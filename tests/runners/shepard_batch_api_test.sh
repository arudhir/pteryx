shepard_cli batch_via_api \
    --account_number 220014408267 \
    --role_to_assume_to_target_account GinkgoSubAdminRole \
    --lambda_to_invoke pteryx-pteryxSchedulerFunctionBatchingEndpoint-1367QVY46IQ0X \
    --json_payload '{"TAG": "test-meso", "NAME": "meso", "LONG": "meso/meso.ont.fq.gz", "SIZE": "0.8M", "LINEAGE": "bacteria", "OUTDIR": ""}'

