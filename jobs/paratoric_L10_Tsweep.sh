#!/bin/bash -l
#SBATCH --job-name=paratoric_L10_T
#SBATCH --partition=cluster
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=00:30:00
#SBATCH --output=logs/paratoric_L10_Tsweep.%j.out
#SBATCH --error=logs/paratoric_L10_Tsweep.%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate paratoric

echo "==== job info ===="
echo "Job ID    : $SLURM_JOB_ID"
echo "Node      : $(hostname)"
echo "CPUs      : $SLURM_CPUS_PER_TASK"
echo "Started   : $(date)"
echo "Sweep     : T from 0.1 to 8.0 at h=0, lambda=0, L=10"
echo "=================="

RUN_DIR=$SCRATCH/paratoric_L10_Tsweep_${SLURM_JOB_ID}
mkdir -p $RUN_DIR
cd $RUN_DIR
mkdir -p out_L10_Tsweep

# pure toric code: h = lambda = 0
# T sweep from 0.1 to 8.0 with 32 points
python3 -u $HOME/ParaToric/python/cli/paratoric.py \
    -sim etc_T_sweep \
    -lat square -L 10 -bound periodic \
    -bas x \
    -Tl 0.1 -Tu 8.0 -Ts 32 \
    -hc 0.0 -hct 0.0 \
    -lmbdac 0.0 -lmbdact 0.0 \
    -Jc 1 -muc 1 \
    -Ns 20000 -Nth 1000000 -Nbs 16000 \
    -Nr 4 \
    -obs energy sigma_x sigma_z anyon_count anyon_density \
    -s 0 -cth 0 -dsp 1 -proc $SLURM_CPUS_PER_TASK -snap 0 -fts 0 \
    -outdir ./out_L10_Tsweep

mkdir -p $HOME/ParaToric/results/T_sweep
cp -r out_L10_Tsweep $HOME/ParaToric/results/T_sweep/L10_Tsweep_${SLURM_JOB_ID}

echo "Finished  : $(date)"
echo "Results   : $HOME/ParaToric/results/T_sweep/L10_Tsweep_${SLURM_JOB_ID}"
