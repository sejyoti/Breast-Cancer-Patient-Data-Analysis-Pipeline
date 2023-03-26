nextflow {
    // Set the Nextflow version and process executor
    version '20.10.0'
    executor {
        docker {
            enabled = true
        }
    }

    // Define input parameters
    params.reads = "$baseDir/data/*.fastq.gz"
    params.gtf = "$baseDir/data/Homo_sapiens.GRCh38.102.gtf"
    params.design = "$baseDir/data/design.csv"

    // Define processes
    process trimmomatic {
        // Define input and output
        input:
            file(reads) from params.reads

        output:
            file "${reads.baseName}_trimmed.fastq.gz" into trimmomatic_output

        // Define the command to run
        """
        trimmomatic PE -threads 4 \
            ${reads} \
            ${reads.baseName}_paired.fastq.gz \
            ${reads.baseName}_unpaired.fastq.gz \
            ${reads.baseName}_paired.fastq.gz \
            ${reads.baseName}_unpaired.fastq.gz \
            ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
            LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 \
            MINLEN:36
        """
    }

    process salmon_index {
        // Define input and output
        input:
            file gtf from params.gtf

        output:
            file "index_salmon/"

        // Define the command to run
        """
        salmon index \
            -t ${gtf} \
            -i index_salmon \
            --type quasi \
            -k 31 \
            --threads 4
        """
    }

    process salmon_quant {
        // Define input and output
        input:
            file "${sample_id}_paired.fastq.gz" from trimmomatic_output

        output:
            file "${sample_id}_quant.sf" into salmon_quant_output

        // Define the command to run
        """
        salmon quant \
            -i ${transcriptome_index} \
            -l A \
            -1 ${sample_id}_paired.fastq.gz \
            -2 ${sample_id}_unpaired.fastq.gz \
            --threads 4 \
            --validateMappings \
            -o ${sample_id}_quant
        """
    }

    process tximport {
        // Define input and output
        input:
            set val(sample_id), file(sf) from "salmon_quant_output/*.sf"

        output:
            file "merged_quant"

        // Define the command to run
        """
        Rscript -e 'library(tximport); files <- c(${sf.join(", ")}); txi <- tximport(files, type = "salmon", tx2gene = ${params.gtf}, ignoreTxVersion = TRUE, countsFromAbundance = "lengthScaledTPM"); write.table(txi$counts, file = "merged_quant", sep = "\t", row.names = TRUE, col.names = FALSE, quote = FALSE)'
        """
    }

    // Define the workflow
    workflow {
        // Parse the design file
        design = readCsv(params.design, sep = ",")

        // Run the pipeline for each sample
        design.each { row ->
            // Define variables for the sample
            sample_id = row.sample_id
            reads = row.fastq
            transcriptome_index = file("index_salmon")

            // Run the processes for the sample
            trimmomatic(reads)
            salmon_index(gtf)
