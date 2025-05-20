###########################################
### Genome Annotation with Prokka        ##
###########################################

rule prokka:
    input:
        fixed_contigs       = OUTPUT_DIR + "{all_genomes}/assembly/contigs_fixed.fasta"
    output:
        gff                 = OUTPUT_DIR + "{all_genomes}/annotation/prokka/prokka.gff",
        faa                 = OUTPUT_DIR + "{all_genomes}/annotation/prokka/prokka.faa",
        gbk                 = OUTPUT_DIR + "{all_genomes}/annotation/prokka/prokka.gbk",
        output_dir          = directory(OUTPUT_DIR + "{all_genomes}/annotation/prokka/")
    params:
        output_dir          = OUTPUT_DIR + "{all_genomes}/annotation/prokka/"
    message:
        "Running Prokka on fixed_contigs"
    conda: 
        "prokka_env"
    shell:
        "rm -rf {params.output_dir}; "
        "mkdir -p {params.output_dir}; "
        "prokka "
        "--outdir {params.output_dir} "
        "--prefix prokka "
        "--cpus {resources.cpus_per_task} "
        "{input.fixed_contigs} "
        "--force; "
