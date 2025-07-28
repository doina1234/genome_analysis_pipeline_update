rule summarize_sample_stats:
    input:
        quast_reports                  = expand(OUTPUT_DIR + "01_qc/quast/{sample}/report.txt", sample=SAMPLES),
        prokka_reports                  = expand(OUTPUT_DIR + "{sample}/annotation/prokka/prokka.txt", sample=SAMPLES)
    output:
        summary                 = OUTPUT_DIR + "01_qc/summary_qc.tsv"
    message:
        "Creating summary with GC, contig count, total length and CDS for each sample"
    run:
        import os
        import re
        import pandas as pd
        
        summary_data = []
        
        quast_map = {}
        for path in input.quast_reports:
            match = re.search(r'/quast/([^/]+)/report\.txt', path)
            if match and os.path.exists(path) and os.path.getsize(path) > 0:
                quast_map[match.group(1)] = path
            else:
                print(f"[WARN] QUAST fehlt oder leer: {path}")
        
        prokka_map = {}
        for path in input.prokka_reports:
            match = re.search(r'/([^/]+)/annotation/prokka/prokka\.txt', path)
            if match and os.path.exists(path) and os.path.getsize(path) > 0:
                prokka_map[match.group(1)] = path
            else:
                print(f"[WARN] PROKKA fehlt oder leer: {path}")
        
        valid_samples = sorted(set(quast_map) & set(prokka_map))
        
        if not valid_samples:
            raise ValueError("No QUAST or prokka reports found")
        
        for sample in valid_samples:
            row = {"sample_name": sample}
        
            try:
                with open(quast_map[sample]) as f:
                    for line in f:
                        if "GC (%)" in line:
                            row["GC (%)"] = line.strip().split()[-1]
                        elif "# contigs" in line:
                            row["# contigs"] = line.strip().split()[-1]
                        elif "Total length" in line:
                            row["Total length"] = line.strip().split()[-1]
            except Exception as e:
                print(f"[ERROR] Error QUAST report txt file {sample}: {e}")
                continue
        
            try:
                with open(prokka_map[sample]) as f:
                    for line in f:
                        if line.startswith("CDS"):
                            row["CDS"] = line.strip().split()[-1]
            except Exception as e:
                print(f"[ERROR] Error prokka txt file {sample}: {e}")
                continue
        
            summary_data.append(row)
        
        df = pd.DataFrame(summary_data)
        df.to_csv(output.summary, sep="\t", index=False)
