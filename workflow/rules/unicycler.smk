##################################################
## Genome Assembly with SPAdes                  ##
##################################################

rule unicycler:
    input:
        trimmed_1           = rules.fastp.output.trimmed_1,
        trimmed_2           = rules.fastp.output.trimmed_2
    output:
        contigs             = OUTPUT_DIR + "{sample}/assembly/unicycler/contigs.fasta"
    message:
        "Run unicycler to assemble trimmed reads"
    conda: 
        "unicycler_env"
    params:
        output_dir          = directory(OUTPUT_DIR + "{sample}/assembly/unicycler/"),
        assembly_dir        = directory(OUTPUT_DIR + "{sample}/assembly/"
    shell:
        "mkdir -p {params.output_dir}; "
        "unicycler.py "
        "-1 {input.trimmed_1} "
        "-2 {input.trimmed_2} "
        "--threads {resources.cpus_per_task} " 
        "-o {params.output_dir}; "
        "cp {params.output_dir}/assembly.fasta {params.assembly_dir}/contigs.fasta; "


