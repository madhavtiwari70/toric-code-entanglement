#!/bin/bash -l
#SBATCH --job-name=paratoric_L_array
#SBATCH --partition=cluster
#SBATCH --array=4,6,8,12
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:15:00
#SBATCH --mem=32G
#SBATCH --output=paratoric_L_array.%A_%a.out
#SBATCH --error=paratoric_L_array.%A_%a.err

# environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate paratoric

# pull L from the array index
L=$SLURM_ARRAY_TASK_ID

# scale thermalization and bin size with lattice size (paper's recipe: ~10000*L^2 and 160*L^2)
NTH=$((10000 * L * L))
NBS=$((160 * L * L))

# diagnostics
echo "==== job info ===="
echo "Array job ID  : $SLURM_ARRAY_JOB_ID"
echo "Task index    : $SLURM_ARRAY_TASK_ID"
echo "Lattice L     : $L"
echo "Nth           : $NTH"
echo "Nbs           : $NBS"
echo "Node          : $(hostname)"
echo "CPUs          : $SLURM_CPUS_PER_TASK"
echo "Started       : $(date)"
echo "=================="

# work in SCRATCH
RUN_DIR=$SCRATCH/paratoric_L${L}_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
mkdir -p $RUN_DIR
cd $RUN_DIR
mkdir -p out_array

# h-sweep at this L, same parameters as before
python3 -u $HOME/ParaToric/python/cli/paratoric.py \
    -sim etc_h_sweep \
    -lat square -L $L -bound periodic \
    -bas x \
    -T 0.25 \
    -hl 0.20 -hu 0.55 -hs 8 -hct 0.0 \
    -Jc 1 -muc 1 \
    -lmbdac 0.2 -lmbdact 0.2 \
    -Ns 20000 -Nth $NTH -Nbs $NBS \
    -Nr 4 \
    -obs energy sigma_x sigma_z anyon_count anyon_density \
    -s 0 -cth 0 -dsp 1 -proc $SLURM_CPUS_PER_TASK -snap 0 -fts 0 \
    -outdir ./out_array

# copy results back
mkdir -p $HOME/ParaToric/results
cp -r out_array $HOME/ParaToric/results/L${L}_array_${SLURM_ARRAY_JOB_ID}

echo "Finished      : $(date)"
echo "Results       : $HOME/ParaToric/results/L${L}_array_${SLURM_ARRAY_JOB_ID}"
