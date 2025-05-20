###################################################
### Compare genome content (PIRATE)              ##
###################################################

rule pirate:
    input:
        gff_files           = expand(OUTPUT_DIR + "temp_genome_gff/{all_genomes}.gff", all_genomes=ALL_GENOMES)
    output:
        alignment_fasta     = OUTPUT_DIR + "pangenome/pirate/core_alignment.fasta" 
    params:
        gff_dir             = OUTPUT_DIR + "temp_genome_gff/",
        output_dir          = OUTPUT_DIR + "pangenome/pirate/"
    message:
        "Compaire genome content using pirate"
    conda: 
        "pirate_env"
    shell:
        "mkdir -p {params.output_dir}; "
        "PIRATE "
        "-i {params.gff_dir} "
        "-s 50,70,90,95,98 "
        "-o {params.output_dir} "
        "-t {resources.cpus_per_task} "
        "-a "
        "-r; "

rule tree_pirate:
    input:
        aln                     = rules.pirate.output.alignment_fasta
    output:
        iqtree_log              = OUTPUT_DIR + "pangenome/iqtree/iqtree.log"
    params:
        #prefix                  = OUTPUT_DIR + "pangenome/iqtree/core_alignment"
    message:
        "Builing phylogeny tree of whole genomes using IQ-Tree"
    conda: 
        "iqtree_env"
    shell:
        "iqtree "
        "-s {input.aln} "
        "-bb 1000 "
        "> {output}; "