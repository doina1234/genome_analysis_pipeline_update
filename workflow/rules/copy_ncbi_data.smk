def get_ncbi_fna(wildcards):
    return PROJECT_DIR + f"ncbi_dataset/data/{wildcards.genome}/{genomes_map[wildcards.genome]}_genomic.fna"

rule copy_ncbi_data:
    input:
        get_ncbi_fna
    output:
        fasta           = WORKING_DIR + "genomes/{genome}.fasta",
        contigs         = OUTPUT_DIR + "{genome}/assembly/contigs_fixed.fasta"
    params:
        outdir = WORKING_DIR + "genomes/"
    shell:
        "mkdir -p {params.outdir}; "
        "echo 'Copying {input} to {output.fasta}'; "
        "cp {input} {output.fasta}; "
        "cp {input} {output.contigs}; "
