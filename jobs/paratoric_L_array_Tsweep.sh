#!/bin/bash -l
#SBATCH --job-name=paratoric_L_T
#SBATCH --partition=cluster
#SBATCH --array=6,8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:30:00
#SBATCH --mem=32G
#SBATCH --output=logs/paratoric_L_array_Tsweep.%A_%a.out
#SBATCH --error=logs/paratoric_L_array_Tsweep.%A_%a.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate paratoric

L=$SLURM_ARRAY_TASK_ID
NTH=$((10000 * L * L))
NBS=$((160 * L * L))

echo "L=$L  Nth=$NTH  Nbs=$NBS  Node=$(hostname)  Start=$(date)"

RUN_DIR=$HOME/ParaToric/scratch_runs/paratoric_L${L}_Tsweep_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
mkdir -p $RUN_DIR
cd $RUN_DIR
mkdir -p out_Tsweep

python3 -u $HOME/ParaToric/python/cli/paratoric.py \
    -sim etc_T_sweep    -lat square -L $L -bound periodic \
    -bas x \
    -Tl 0.1 -Tu 8.0 -Ts 32 \
    -hc 0.0 -hct 0.0 \
    -lmbdac 0.0 -lmbdact 0.0 \
    -Jc 1 -muc 1 \
    -Ns 20000 -Nth $NTH -Nbs $NBS \
    -Nr 4 \
    -obs energy sigma_x sigma_z anyon_count anyon_density \
    -s 0 -cth 0 -dsp 1 -proc $SLURM_CPUS_PER_TASK -snap 0 -fts 0 \
    -outdir ./out_Tsweep

mkdir -p $HOME/ParaToric/results/T_sweep
cp -r out_Tsweep $HOME/ParaToric/results/T_sweep/L${L}_Tsweep_${SLURM_ARRAY_JOB_ID}

echo "End=$(date)"
