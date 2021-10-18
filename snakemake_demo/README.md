# Snakemake demo

This is a toy Snakemake workflow for demonstrating some of the capabilities of Snakemake. This repo contains fastq files from two strains of mice in 'raw_data/' downloaded from the SRA using the 'get_fqs.sh' script included. The Snakemake workflow aligns the raw reads to the reference genome indicated in 'bin/config.yaml' using `bwa mem` then calls variants using `bcftools`.

## Exercises

All the exercises below assume that you have Snakemake in your PATH (you can run `module load bbc/snakemake/snakemake-6.1.0`) and that you are in the 'snakemake_demo/' directory.

### Ex 1
- Run `snakemake -npr` to see the different jobs that will be run by Snakemake.
- Run `snakemake --dag | dot -Tpng > dag.png`. Take a look at the figure; this is a useful way to summarize your workflow in a figure. For projects with many samples, you can try `snakemake --rulegraph | dot -Tpng > dag.png`.

### Ex 2
In Ex 1, we learned what jobs will be run by the workflow. Here let's go ahead and run these jobs via the PBS job system on the HPC. First open up 'bin/run_snakemake.sh' and look at the code; the '--cluster' option in this invocation of Snakemake tells it how to submit each job to the HPC.

Let's go ahead and run this workflow by running `qsub bin/run_snakemake.sh`. Next run, `qstat -u firstname.lastname` to watch the progress of your main workflow job and the child jobs that it submits in order to complete the workflow. Keep checking using `qstat` until all the jobs complete.

Run `cat logs/snake_workflow.e`. If everything run successfully, it should say '100%' completed at the end of the file.

### Ex 3
Recall that Snakemake determines what jobs needs to be run based on whether the target files are present. In our case, these target files are defined in the 'input' of the 'all' rule.  Re-run the first command from Ex 1. What do you see now?

Rename the directory containing the BAM files by running `mv analysis/bwamem analysis/foo_bwamem`. Run `snakemake -npr` again. Did anything change? Why not? Change the directory name back to the original name using `mv analysis/foo_bwamem analysis/bwamem`.

Now rename the directory containing the VCF files (`mv analysis/bcftools_call analysis/foo_bcftools_call`) and check again. Can you explain why Snakemake wants to run jobs now? Don't change the directory name back just yet.

### Ex 4
You may have noticed that there is an unused rule in the 'Snakefile' called 'filt_bams'. This rule filter for only properly paired and unduplicated alignments. Can you modify the workflow so that the 'bcftools_call' rule uses these filtered alignments for variant calling? You need to make a simple change to two lines of code. Confirm that the 'filt_bams' rule is going to be run by running `snakemake -npr` again. Produce the DAG figure from Ex 1 again to see the additional jobs in the DAG. Note how using a workflow manager makes it easy to modify parts of your workflow by making the workflow more modular. 

When you are done, run `mv analysis/foo_bcftools_call analysis/bcftools_call` to change the directory name back.

### Ex 5
Look at the 'bcftools_call' rule in the 'Snakefile'. Note that we ask 'bcftools mpileup' to consider only alignments with a MAPQ score of >=30. What if we want to compare the variant calls using alignments with a minimum MAPQ of 10 versus 30? The workflow is written so that you can modify (or add) just one line of code to obtain variant calls using two different minimum MAPQ settings. Try to make this modification and run `snakemake -npr` again; note the additional jobs to be run.

Note how powerful it is to be able to easily test different settings or combination of settings using a workflow manager.

### BONUS: Ex 6
The two samples we have been working with represent two different strains of mice (see 'bin/samples.tsv'). Sometimes it is desirable to rename files to biologically meaningful names from the beginning so that all downstream files also have biologically meaningful names. Can you write a new rule to rename the fastq files based on the 'strain' column in the samplesheet and make the bwamem rule use these as input instead? Ideally, this new rule would use `ln -sr {fastq_file} {new_file}` to make use of symlinks instead of having to store a second copy of each fastq file.
