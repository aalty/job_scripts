#!/bin/bash
srun iperf -c athena01 -b 100M -n 10000M 
