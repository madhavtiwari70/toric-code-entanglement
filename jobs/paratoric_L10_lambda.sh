#!/bin/bash -l
#SBATCH --job-name=paratoric_L10_lam
#SBATCH --partition=cluster
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=00:15:00
#SBATCH --output=paratoric_L10_lambda.%j.out
#SBATCH --error=paratoric_L10_lambda.%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate paratoric

echo "==== job info ===="
echo "Job ID    : $SLURM_JOB_ID"
echo "Node      : $(hostname)"
echo "CPUs      : $SLURM_CPUS_PER_TASK"
echo "Started   : $(date)"
echo "Sweep     : lambda 0.0 -> 0.6 at fixed h=0.30"
echo "=================="

RUN_DIR=$SCRATCH/paratoric_L10_lambda_${SLURM_JOB_ID}
mkdir -p $RUN_DIR
cd $RUN_DIR
mkdir -p out_L10_lambda

python3 -u $HOME/ParaToric/python/cli/paratoric.py \
    -sim etc_lmbda_sweep \
    -lat square -L 10 -bound periodic \
    -bas x \
    -T 0.25 \
    -hc 0.30 \
    -lmbdal 0.0 -lmbdau 0.6 -lmbdas 8 -lmbdact 0.0 \
    -Jc 1 -muc 1 \
    -Ns 20000 -Nth 1000000 -Nbs 16000 \
    -Nr 4 \
    -obs energy sigma_x sigma_z anyon_count anyon_density \
    -s 0 -cth 0 -dsp 1 -proc $SLURM_CPUS_PER_TASK -snap 0 -fts 0 \
    -outdir ./out_L10_lambda

mkdir -p $HOME/ParaToric/results
cp -r out_L10_lambda $HOME/ParaToric/results/L10_lambda_${SLURM_JOB_ID}

echo "Finished  : $(date)"
echo "Results   : $HOME/ParaToric/results/L10_lambda_${SLURM_JOB_ID}"
