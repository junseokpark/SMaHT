#!/usr/bin/env python
# -*-coding:utf-8 -*-
'''
@Time: 2024/01/23
@Author: Yu Wei Zhang
@Contact: yuwei_zhang@hms.harvard.edu
'''

import pysam
import argparse, sys, multiprocessing
# from check_missed_seq import get_chromosomes
import random

class DownsampleBam:
    def __init__(self,
                 bam_file,
                 outbam_file,
                 fraction,
                 chunk_size=10000000,
                 threads=16):
        self.bam_file = bam_file
        self.outbam_file = outbam_file
        self.inf = None
        self.outf = None
        self.fraction = fraction
        self.chunk_size = chunk_size
        self.threads = threads
        self.selected = {}
        self.unselected = {}
        self.n_total = 0
    
    def run(self):
        self.inf = pysam.AlignmentFile(self.bam_file, "rb")
        self.outf = pysam.AlignmentFile(self.outbam_file, "wb", template=self.inf)

        # ref_len = get_chromosomes(self.bam_file)
        # fetch_list = []
        # for contig, length in ref_len.items():
        #     for i in range(0, max(length // self.chunk_size, 1)):
        #         reg_start = i * self.chunk_size
        #         reg_end = (i+1) * self.chunk_size
        #         if length - reg_end < self.chunk_size:
        #             reg_end = length
        #         fetch_list.append((contig, reg_start, reg_end))
        # for region in fetch_list:
        #     self.downsample_bam(region)
        self.downsample_bam(None)
        self.inf.close()
        self.outf.close()
        
    def downsample_bam(self, region):
        if region is None:
            for read in self.inf.fetch():
                self.n_total += 1
                if read.query_name in self.selected:
                    self.outf.write(read)
                elif read.query_name in self.unselected:
                    pass
                else:
                    if random.random() < self.fraction:
                        self.outf.write(read)
                        self.selected[read.query_name] = 1
                    else:
                        self.unselected[read.query_name] = 1
            return
        contig, reg_start, reg_end = region
        for read in self.inf.fetch(contig, reg_start, reg_end):
            self.n_total += 1
            if read.query_name in self.selected:
                self.outf.write(read)
            elif read.query_name in self.unselected:
                pass
            else:
                if random.random() < self.fraction:
                    self.outf.write(read)
                    self.selected[read.query_name] = 1
                else:
                    self.unselected[read.query_name] = 1
        

def main():
    parser = argparse.ArgumentParser(description='Downsample bam file')
    parser.add_argument('-i', '--bam', type=str, help='Input bam file', required=True)
    parser.add_argument('-o', '--out', type=str, help='Output bam file')
    parser.add_argument('-t', '--threads', type=int, help='Number of threads', default=16)
    parser.add_argument('-s', '--chunk_size', type=int, help='Chunk size', default=10000000)
    parser.add_argument('-f', '--fration', type=float, help='The posibility of a read being selected', default=1.0)
    args = parser.parse_args()

    if args.out is None:
        args.out = args.bam.replace('.bam', '.downsample.bam')
    
    DownsampleBam(args.bam, args.out, args.fration, args.chunk_size, args.threads).run()

if __name__ == "__main__":
    main()