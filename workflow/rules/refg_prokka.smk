from snakemake.io import ancient

rule refg_prokka:
    input:
        fasta = ancient(WORKING_DIR + "reference/refg.fasta")
    output:
        refg_gbk = WORKING_DIR + "reference/refg.gbk"
    params:
        gbk = WORKING_DIR + "reference/prokka/prokka.gbk",
        output_dir = WORKING_DIR + "reference/prokka/"
    message:
        "Annotating reference fasta with Prokka"
    conda: "prokka_env"
    shell:
        "rm -rf {params.output_dir}; "
        "mkdir -p {params.output_dir}; "
        "prokka --outdir {params.output_dir} "
        "--prefix prokka "
        "--cpus {resources.cpus_per_task} "
        "{input.fasta} "
        "--force; "
        "cp {params.gbk} {output.refg_gbk};"