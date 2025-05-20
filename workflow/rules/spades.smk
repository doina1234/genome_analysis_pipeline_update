##################################################
## Genome Assembly with SPAdes                  ##
##################################################

rule spades:
    input:
        trimmed_1           = rules.fastp.output.trimmed_1,
        trimmed_2           = rules.fastp.output.trimmed_2
    output:
        contigs             = OUTPUT_DIR + "{sample}/assembly/contigs.fasta"
    message:
        "Run Spades to assemble trimmed reads"
    conda: 
        "spades_env"
    params:
        output_dir          = OUTPUT_DIR + "{sample}/assembly/spades/",
        contigs_spades       = OUTPUT_DIR + "{sample}/assembly/spades/contigs.fasta",
        contigs_fix         = OUTPUT_DIR + "{sample}/assembly/spades/contigs_fix.fasta",
        assembly_dir        = OUTPUT_DIR + "{sample}/assembly/"
    shell:
        "mkdir -p {params.output_dir}; "
        "spades.py "
        "-1 {input.trimmed_1} "
        "-2 {input.trimmed_2} "
        "--isolate "
        "--threads {resources.cpus_per_task} " 
        "-o {params.output_dir}; "
        "echo {params.contigs_spades}; "
        "cp {params.contigs_spades} {output.contigs}; "


rule fix_contigs:
    input:
        contigs             = OUTPUT_DIR + "{sample}/assembly/contigs.fasta",
    output:
        fixed_contigs       = OUTPUT_DIR + "{sample}/assembly/contigs_fixed.fasta"
    message:
        "Fix lenght of contig names and remove contigs < 200bp"
    conda: 
        "seqkit_env"
    shell:
        """
        seqkit seq -m 200 {input.contigs} | awk '/^>/ {{print substr($0,1,20); next}} 1' > {output.fixed_contigs}
        """



