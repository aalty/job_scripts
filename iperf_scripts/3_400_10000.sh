#!/bin/bash
srun iperf -c athena01 -b 400M -n 10000M 
