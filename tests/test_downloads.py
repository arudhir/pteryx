# from pteryx.run import download


# @setup_batch_env
# def test_download_ilmn_samples():
    # ilmn = [50960866]
    # result = download(ilmn=ilmn, fastq_from_sample_id=True)
    # for readpath in result["illumina"]:
        # assert readpath


# @setup_batch_env
# def test_download_ont_samples():
    # ont = [50698664]
    # result = download(ont=ont, fastq_from_sample_id=True)
    # for readpath in result["nanopore"]:
        # assert readpath.exists()


# @setup_batch_env
# def test_download_s3_samples():
    # r1 = "s3://ginkgo-seqdb-803444171345-128a6133-us-east-2/simulated-reads/mesoplasma_simulated.1.fq.gz"
    # r2 = "s3://ginkgo-seqdb-803444171345-128a6133-us-east-2/simulated-reads/mesoplasma_simulated.2.fq.gz"
    # ont = "s3://ginkgo-seqdb-803444171345-128a6133-us-east-2/simulated-reads/mesoplasma_simulated.ont.fq.gz"

    # result = download(ilmn=[r1, r2], ont=[ont])
    # for readpath in result["illumina"]:
        # assert readpath.exists()
    # for readpath in result["nanopore"]:
        # assert readpath.exists()
