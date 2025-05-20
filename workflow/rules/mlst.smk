###########################################
### MLST typing                          ##
###########################################


rule run_mlst:
    input:
        fasta                   = expand(rules.copy_prokka_to_temp.output.temp_fasta, all_genomes=ALL_GENOMES)
    output:
        mlst_tsv                = OUTPUT_DIR + "typing/mlst/mlst.tsv"
    params:
        fasta_dir               = OUTPUT_DIR + "temp_genome_fasta/",
        mlst_dir                = OUTPUT_DIR + "typing/mlst/"
    message:
        "Running MLST typing on all genome files"
    conda: 
        "mlst_env"
    shell:
        "mlst {params.fasta_dir}* > {output.mlst_tsv}"


