
rule abricate:
    input:
        fasta                   = OUTPUT_DIR + "{all_genomes}/assembly/contigs_fixed.fasta"
    output:
        ncbi                    = OUTPUT_DIR + "amr/{all_genomes}.ncbi.tsv",
        resfinder               = OUTPUT_DIR + "amr/{all_genomes}.resfinder.tsv",
        plasmidfinder           = OUTPUT_DIR + "amr/{all_genomes}.plasmidfinder.tsv"
    params:
        output_dir              = OUTPUT_DIR + "amr/"
    message:
        "Screen for amr genes"
    conda: 
        "abricate_env"
    shell:
        "mkdir -p {params.output_dir}; "
        "abricate --db ncbi {input.fasta} > {output.ncbi}; "
        "abricate --db resfinder {input.fasta} > {output.resfinder}; "
        "abricate --db plasmidfinder {input.fasta} > {output.plasmidfinder}; "


#rule summarize_abricate:
#    input:
#        tsvs                    = expand(OUTPUT_DIR + "amr/{all_genomes}.{db}.tsv",
#                                all_genomes=GENOMES,
#                                db=["ncbi", "resfinder", "plasmidfinder"])
#    output:
#        summary_table           = OUTPUT_DIR + "amr/resistance_summary.tsv"
#    params:
#        output_dir              = OUTPUT_DIR + "amr/"
#    message:
#        "Summarizing Abricate resistance results across all_genomess"
#    conda:
#        "abricate_r_env" 
#    shell:
#        "mkdir -p {params.output_dir}; "
#        "python scripts/summarize_abricate.py {input.tsvs} {output.summary_table}"




#rule amr_heatmap:
#    input:
#        ncbi                    = expand(rules.abricate.output.ncbi, all_genomes=all_genomesS),
#        resfinder               = expand(rules.abricate.output.resfinder, all_genomes=all_genomesS),
#        plasmidfinder           = expand(rules.abricate.output.plasmidfinder, all_genomes=all_genomesS)
#    output:
#        heatmap                 = OUTPUT_DIR + "amr/heatmap.png",
#        matrix                  = OUTPUT_DIR + "amr/abricate_presence_absence.tsv"
#    conda:
#        "abricate_env"
#    run:
#        import matplotlib.pyplot as plt
#        import seaborn as sns
#        import os
#
#        all_hits = {}
#
#        # Parse all abricate outputs
#        for all_genomes, files in zip(all_genomesS, zip(input.ncbi, input.resfinder, input.plasmidfinder)):
#            genes = set()
#            for f in files:
#                df = pd.read_csv(f, sep='\t', comment='#')
#                if 'GENE' in df.columns:
#                    genes.update(df['GENE'].unique())
#            all_hits[all_genomes] = genes
#
#        # Build presence/absence matrix
#        all_genes = sorted(set.union(*all_hits.values()))
#        matrix = pd.DataFrame(0, index=all_genomesS, columns=all_genes)
#
#        for all_genomes, genes in all_hits.items():
#            matrix.loc[all_genomes, list(genes)] = 1
#
#        # Save matrix
#        matrix.to_csv(output.matrix, sep="\t")
#
#        # Plot heatmap
#        plt.figure(figsize=(len(all_genes) * 0.5, len(GENOMES) * 0.5))
#        sns.heatmap(matrix, cmap="Greys", cbar=False, linewidths=0.5, linecolor='grey')
#        plt.xticks(rotation=90)
#        plt.tight_layout()
#        plt.savefig(output.heatmap)