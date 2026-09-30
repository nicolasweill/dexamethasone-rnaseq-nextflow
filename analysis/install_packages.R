# Installation des paquets nécessaires à deseq2_analysis.qmd (à exécuter une seule fois).
options(repos = c(CRAN = "https://cloud.r-project.org"))   # obligatoire en mode script (Rscript)

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")

cran <- c("tidyverse", "pheatmap", "knitr", "rmarkdown")
bioc <- c("tximport", "DESeq2", "apeglm", "limma", "EnhancedVolcano",
          "clusterProfiler", "org.Hs.eg.db")

install.packages(setdiff(cran, rownames(installed.packages())))
BiocManager::install(setdiff(bioc, rownames(installed.packages())), ask = FALSE, update = FALSE)

# Vérification
ok <- sapply(c(cran, bioc), requireNamespace, quietly = TRUE)
print(ok)
if (!all(ok)) stop("Paquets manquants : ", paste(names(ok)[!ok], collapse = ", "))
