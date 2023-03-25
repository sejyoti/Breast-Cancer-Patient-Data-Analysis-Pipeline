# Breast-Cancer-Patient-Data-Analysis-Pipeline
This is a Nextflow pipeline for analyzing breast cancer patient data using RNA-seq technology.


<img src="https://www.python.org/static/community_logos/python-logo.png" alt="Python logo" width="200">
<img src="https://raw.githubusercontent.com/nf-core/logos/main/nf-core-logo.svg" alt="nf-core logo" width="200">


Overview
The pipeline takes raw RNA-seq reads in fastq format, trims them using Trimmomatic, quantifies gene expression using Salmon, and merges the quantification data using tximport. The pipeline is designed to work with the Homo sapiens GRCh38 reference genome and gene annotation files.


# Breast Cancer Patient Data Analysis Pipeline

This is a Nextflow pipeline for analyzing breast cancer patient data using RNA-seq technology.

## Overview

The pipeline takes raw RNA-seq reads in fastq format, trims them using Trimmomatic, quantifies gene expression using Salmon, and merges the quantification data using tximport. The pipeline is designed to work with the Homo sapiens GRCh38 reference genome and gene annotation files.

## Requirements

- Nextflow (version 21.04.3 or later)
- Trimmomatic (version 0.39 or later)
- Salmon (version 1.4.0 or later)







