#!/bin/bash
srun iperf -c athena01 -b 200M -n 5000M
