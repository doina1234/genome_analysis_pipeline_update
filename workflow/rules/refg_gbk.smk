def get_ref_gbk_path(wildcards):
    ref_dir = os.path.join(WORKING_DIR, "reference")
    standard_ref = os.path.join(ref_dir, "refg.gbk")

    if os.path.exists(standard_ref):
        print(f"✔ Using custom reference: {standard_ref}")
        return standard_ref

    gbk_candidates = [f for f in os.listdir(ref_dir) if f.endswith(".gbk")]
    if gbk_candidates:
        custom_gbk = os.path.join(ref_dir, gbk_candidates[0])
        print(f"✔ Found existing .gbk: {custom_gbk} → will copy to refg.gbk")
        return custom_gbk

    ref_list = config.get("refg", [])
    ref_sample = ref_list[0] if ref_list else sorted(ALL_GENOMES)[0]
    default_gbk = os.path.join(OUTPUT_DIR, ref_sample, "annotation", "prokka", "prokka.gbk")
    print(f"✔ Using Prokka gbk from sample: {ref_sample}")
    return default_gbk


rule refg_gbk:
    input:
        gbk_in = get_ref_gbk_path
    output:
        gbk = WORKING_DIR + "reference/refg.gbk"
    message:
        "Copying or linking selected reference .gbk to 'refg.gbk'"
    run:
        import shutil
        import os

        if os.path.abspath(input.gbk_in) != os.path.abspath(output.gbk):
            print(f"✔ Copying {input.gbk_in} → {output.gbk}")
            shutil.copy(input.gbk_in, output.gbk)
        else:
            print("✔ refg.gbk already in place — no copy needed.")