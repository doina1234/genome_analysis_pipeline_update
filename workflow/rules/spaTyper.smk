###################################################
### Compute Spa Type Calculation                 ##
###################################################

rule spa_typing:
    input:
        contigs                 = OUTPUT_DIR + "{all_genomes}/assembly/contigs_fixed.fasta"
    output:
        spatype                 = OUTPUT_DIR + "typing/spaTyper/{all_genomes}_spatype.txt"
    params:
        output_dir              = OUTPUT_DIR + "typing/spaTyper/"
    message:
        "Compute Spa Type Calculation"
    conda: 
        "spaTyper_env"
    shell:
        "mkdir -p {params.output_dir}; "
        "spaTyper "
        "-f {input.contigs} "
        "--output {output.spatype}; "
