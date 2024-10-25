#!/bin/bash

cat <<-EOF

Welcome to the Dashboard UI Installer!

This will install the UI locally.

EOF

sleep 2

# Change directory
pushd ./app
# Clean Up if necessary
rm -rf venv
rm -rf __pycache__
# Set Python environment
python3 -m venv venv
source venv/bin/activate
# Install requirements
python3 -m pip install -r requirements.txt
# Deploy the local website at port 8000
uvicorn app:app --reload