#!/bin/bash
srun iperf -c athena01 -b 300M -n 15000M 
