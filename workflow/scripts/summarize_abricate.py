import pandas as pd
import glob
import os

# Path to your Abricate results
input_dir = "amr/"
output_file = "amr_summary_table.csv"

# Collect all .tsv files
tsv_files = glob.glob(os.path.join(input_dir, "*.tsv"))

# Dictionary to store gene presence per sample
sample_gene_map = {}

# Process each file
for file in tsv_files:
    sample_name = os.path.basename(file).split(".")[0]
    df = pd.read_csv(file, sep="\t", comment="#", dtype=str)

    if "GENE" in df.columns:
        found_genes = df["GENE"].dropna().tolist()
        sample_gene_map.setdefault(sample_name, set()).update(found_genes)

# Create full set of genes
all_genes = sorted(set(gene for genes in sample_gene_map.values() for gene in genes))

# Build the binary matrix
presence_matrix = pd.DataFrame(0, index=sorted(sample_gene_map.keys()), columns=all_genes)

for sample, genes in sample_gene_map.items():
    presence_matrix.loc[sample, list(genes)] = 1

# Save as CSV
presence_matrix.to_csv(output_file)

print(f"✅ Summary table saved to {output_file}")