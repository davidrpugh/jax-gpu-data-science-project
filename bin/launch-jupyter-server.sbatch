#!/bin/bash --login
#SBATCH --time 2:00:00
#SBATCH --gpus-per-node=v100:1
#SBATCH --cpus-per-gpu=6  
#SBATCH --mem-per-gpu=64G 
#SBATCH --partition=batch
#SBATCH --job-name=launch-jupyter-server
#SBATCH --mail-type=ALL
#SBATCH --output=bin/%x-%j-slurm.out
#SBATCH --error=bin/%x-%j-slurm.err

# setup the environment
module purge
export ENV_PREFIX=$PWD/env
conda activate $ENV_PREFIX

# see https://github.com/google/jax#installation for details
export XLA_FLAGS=--xla_gpu_cuda_data_dir=$ENV_PREFIX

# setup ssh tunneling 
export XDG_RUNTIME_DIR=/tmp IBEX_NODE=$(hostname -s) 
KAUST_USER=$(whoami) 
JUPYTERLAB_PORT=8888 
 
echo "
To connect to the compute node ${IBEX_NODE} on Ibex running your JupyterLab server, 
you need to create an ssh tunnel from your local machine to glogin node on Ibex 
using the following command.

ssh -L ${JUPYTERLAB_PORT}:${IBEX_NODE}:${JUPYTERLAB_PORT} ${KAUST_USER}@glogin.ibex.kaust.edu.sa 

Next, you need to copy the second url provided below and paste it into the browser 
on your local machine.
" >&2

# launch jupyter server 
jupyter ${1:-lab} --no-browser --port=${JUPYTERLAB_PORT} --ip=${IBEX_NODE} 
