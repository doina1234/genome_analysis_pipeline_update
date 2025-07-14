rule summarize_sample_stats:
    input:
        quast_reports                  = expand(OUTPUT_DIR + "01_qc/quast/{sample}/report.txt", sample=SAMPLES),
        prokka_reports                  = expand(OUTPUT_DIR + "{sample}/annotation/prokka/prokka.txt", sample=SAMPLES)
    output:
        summary                 = OUTPUT_DIR + "01_qc/summary_qc.tsv"
    message:
        "Creating summary with GC, contig count, total length and CDS for each sample"
    run:
        import re
        import pandas as pd

        summary_data = []

        quast_map = {re.search(r'/quast/([^/]+)/report\.txt', path).group(1): path for path in input.quast_reports}
        prokka_map = {re.search(r'/output/([^/]+)/annotation/prokka/prokka\.txt', path).group(1): path for path in input.prokka_reports}

        for sample in sorted(quast_map.keys()):
            row = {"sample_name": sample}

            with open(quast_map[sample]) as f:
                for line in f:
                    if "GC (%)" in line:
                        row["GC (%)"] = line.strip().split()[-1]
                    elif "# contigs" in line:
                        row["# contigs"] = line.strip().split()[-1]
                    elif "Total length" in line:
                        row["Total length"] = line.strip().split()[-1]

            with open(prokka_map[sample]) as f:
                for line in f:
                    if line.startswith("CDS"):
                        row["CDS"] = line.strip().split()[-1]

            summary_data.append(row)

        df = pd.DataFrame(summary_data)
        df.to_csv(output.summary, sep="\t", index=False)