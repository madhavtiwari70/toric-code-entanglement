#!/bin/bash -l
#SBATCH --job-name=paratoric_L10
#SBATCH --partition=cluster
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=00:15:00
#SBATCH --output=paratoric_L10.%j.out
#SBATCH --error=paratoric_L10.%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate paratoric

echo "==== job info ===="
echo "Job ID    : $SLURM_JOB_ID"
echo "Node      : $(hostname)"
echo "CPUs      : $SLURM_CPUS_PER_TASK"
echo "Started   : $(date)"
echo "=================="

RUN_DIR=$SCRATCH/paratoric_L10_${SLURM_JOB_ID}
mkdir -p $RUN_DIR
cd $RUN_DIR
mkdir -p out_L10

python3 -u $HOME/ParaToric/python/cli/paratoric.py \
    -sim etc_h_sweep \
    -lat square -L 10 -bound periodic \
    -bas x \
    -T 0.25 \
    -hl 0.20 -hu 0.55 -hs 8 -hct 0.0 \
    -Jc 1 -muc 1 \
    -lmbdac 0.2 -lmbdact 0.2 \
    -Ns 20000 -Nth 1000000 -Nbs 16000 \
    -Nr 4 \
    -obs energy sigma_x sigma_z anyon_count anyon_density \
    -s 0 -cth 0 -dsp 1 -proc $SLURM_CPUS_PER_TASK -snap 0 -fts 0 \
    -outdir ./out_L10

mkdir -p $HOME/ParaToric/results
cp -r out_L10 $HOME/ParaToric/results/L10_${SLURM_JOB_ID}

echo "Finished  : $(date)"
echo "Results   : $HOME/ParaToric/results/L10_${SLURM_JOB_ID}"
