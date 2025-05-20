rule generate_refg_fasta:
    input:
        fasta = OUTPUT_DIR + f"{REF_SAMPLE}/assembly/contigs_fixed.fasta"
    output:
        refg_fasta = WORKING_DIR + "reference/refg.fasta"
    message:
        "No manual reference provided — using {input.fasta}"
    shell:
        "mkdir -p $(dirname {output.refg_fasta}); "
        "cp {input.fasta} {output.refg_fasta}"