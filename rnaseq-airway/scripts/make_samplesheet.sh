#!/usr/bin/env bash
# Construit samplesheet.csv à partir de metadata.csv et des FASTQ téléchargés par fetchngs.
set -euo pipefail

FQ_DIR="fetchngs_results/fastq"
echo "sample,fastq_1,fastq_2,strandedness" > samplesheet.csv

tail -n +2 metadata.csv | while IFS=, read -r run sample cell dex; do
  r1="$FQ_DIR/${run}_1.fastq.gz"
  r2="$FQ_DIR/${run}_2.fastq.gz"
  [[ -f "$r1" && -f "$r2" ]] || { echo "FASTQ manquant pour $run" >&2; exit 1; }
  echo "$sample,$(realpath "$r1"),$(realpath "$r2"),unstranded" >> samplesheet.csv
done

echo "samplesheet.csv écrit :"; cat samplesheet.csv
