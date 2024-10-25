#!/bin/bash

cd /root/ui_poc/app
rm -r venv
rm -r __pycache__
python3 -m venv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
uvicorn app:app --reload