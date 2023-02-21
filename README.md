# Pipelinix

## Overview

Pipelinix is a data version control tool with supporting data pipeline.
The design points are high performance, serverless, composable and easy to use.

Version control for large-scale data is difficult to perform at high speed.
Having a separate hash for each file is slow. 
Existing technologies Git-LFS, Git-Annex, [DVC](https://dvc.org/) all take that approach.
This project uses [Nix](https://nixos.org/) as backend to get a hash for each command not each file.
It is faster than existing technology. 
Compression of data is possible because symbolic links can be used for data.

Unlike cloud services, Pipelinix can be used offline without a server.
To take a backup, just push it to another server at that time.

It can combine external git pipelines as well as local pipelines.

This project provides a wrapper to control the pipeline with a makefile-like yaml file for ease of use.
The wrapper separates the domain of the pipeline and the domain of preparing the command for execution.

## Files

* pipeline.yaml : A configuation file of pipelinix 
* pipeline.nix : A file made from pipeline.yaml
* flake.nix : 
* flake.lock : 

## Install

```shell
nix profile install --accept-flake-config github:junjihashimoto/pipelinix/latest 
```

## Usage

1. Write pipeline.yaml as below

```yaml
pre-processing:
  command: |
    echo "{\"a\":1, \"b\":2}" > $out/hello.json

main:
  parameters:
    - input
  command: |
    ${pkgs.jq}/bin/jq '.' < ${input}/hello.json > $out/hello.json

default:
  compose:
    - self.pre-processing
    - self.main
```

2. Run 'run' command of pipelinix


## Demo

See the 'examples' directory of this repo.
