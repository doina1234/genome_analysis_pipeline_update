rule fix_contigs:
    input:
        contigs             = OUTPUT_DIR + "{all_genomes}/assembly/contigs.fasta",
    output:
        fixed_contigs       = OUTPUT_DIR + "{all_genomes}/assembly/contigs_fixed.fasta"
    message:
        "Fix lenght of contig names and remove contigs < 200bp"
    conda: 
        "seqkit_env"
    shell:
        """
        seqkit seq -m 200 {input.contigs} | awk '/^>/ {{print substr($0,1,20); next}} 1' > {output.fixed_contigs}
        """



