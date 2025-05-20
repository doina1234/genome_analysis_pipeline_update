rule snp_pyseer:
    input:
        vcfs                    = expand(rules.copy_snippy_to_temp.output.temp_vcf, sample=ALL_GENOMES),
        rename_map              = "meta/samples.rename.txt",
        tree = "phylogeny/tree.nwk",
        phenotype = "meta/Phenotype_Colonising0Invasive1.txt",
        script_phylo = "scripts/phylogeny_distance.py"
    output:
        vcf_renamed = "gwas/renamed.vcf.gz",
        vcf_index = "gwas/renamed.vcf.gz.tbi",
        distances = "gwas/phylogeny_distances.tsv",
        results = "gwas/results_pyseer.tsv"
    conda:
        "envs/pyseer.yaml"
    threads: 4
    shell:
        """
        mkdir -p gwas/ gwas/tmp/

        # Step 1-2: Index all input VCFs
        for vcf in {input.vcfs}; do
            bcftools index "$vcf"
        done

        # Step 3: Merge all VCFs into one multisample VCF
        bcftools merge {input.vcfs} -Oz -o gwas/tmp/merged.vcf.gz

        # Step 4-6: Reheader and index
        bcftools reheader -s {input.rename_map} -o {output.vcf_renamed} gwas/tmp/merged.vcf.gz
        tabix -p vcf {output.vcf_renamed}

        # Step 7: Compute distance matrix
        python {input.script_phylo} {input.tree} > {output.distances}

        # Step 8: Run PySEER
        pyseer --phenotypes {input.phenotype} \
               --vcf {output.vcf_renamed} \
               --distances {output.distances} \
               > {output.results}
        """
