###################################################
### Copy annotation files to a temporary folder  ##
###################################################

rule copy_prokka_to_temp:
    input:
        faa                     = rules.prokka.output.faa,
        gff                     = rules.prokka.output.gff,
        fasta                   = OUTPUT_DIR + "{all_genomes}/assembly/contigs_fixed.fasta"
    output:
        temp_faa                = OUTPUT_DIR + "temp_genome_faa/{all_genomes}.faa",
        temp_gff                = OUTPUT_DIR + "temp_genome_gff/{all_genomes}.gff",
        temp_fasta              = OUTPUT_DIR + "temp_genome_fasta/{all_genomes}.fasta"
    params:
        output_dir_faa          = OUTPUT_DIR + "temp_genome_faa/",
        output_dir_gff          = OUTPUT_DIR + "temp_genome_gff/",
        output_dir_fasta        = OUTPUT_DIR + "temp_genome_fasta/"
    message:
        "Copying annotaion files to temp folder"
    shell:
        "mkdir -p {params.output_dir_faa}; "
        "mkdir -p {params.output_dir_gff}; "
        "mkdir -p {params.output_dir_fasta}; "
        "cp {input.faa} {output.temp_faa}; "
        "cp {input.gff} {output.temp_gff}; "
        "cp {input.fasta} {output.temp_fasta}; "




