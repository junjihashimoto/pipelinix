{pkgs ? import <nixpkgs> {}}:
pkgs.writeScriptBin "pipelinix" ''
#!/usr/bin/env bash

set -e

command=$1
if [[ ! -z $command ]]; then
    shift
fi

genjson () {
    mkdir -p .pipelinix/touch
    nix eval --impure --expr 'builtins.mapAttrs (name: value: if builtins.isFunction(value) then {type="process";} else {type="drv"; value=value;}) (import ./pipeline.nix {})' --json > .pipelinix/drvs.json
}

show-flow () {
    drv=$1
    level=$2
    name=`nix show-derivation $drv | jq -r '.[]|.env.name'`
    for((i=0;i<level-1;i++)); do
	echo -n " "
    done
    if [ $level -ne 0 ] ; then
	echo -n " L "
    fi
    echo "$name ($drv)"
    inputDrvs=`nix show-derivation $drv | jq -r '.[]|.["inputDrvs"]|keys[]'`
    for i in $inputDrvs ; do
	if nix show-derivation $i | jq -r '.[]|.env.buildCommand' | grep '^#pipeline-process' >& /dev/null ; then
	    show-flow $i $((level+1))
	fi
    done
}

case $command in
    init)
	echo "init"
    ;;
    run)
	genjson
	touch .pipelinix/touch/"$1"
	nix build -f ./pipeline.nix -o $1 $1 -L
    ;;
    show)
	genjson
	nix-shell -p json2yaml --run json2yaml < .pipelinix/drvs.json
    ;;
    show-flow)
	genjson
	drv=`jq -r ".[\"$1\"].value" .pipelinix/drvs.json`
	show-flow $drv 0
        # jq '.[] | select(.type == "drv") | .["value"]' .pipelinix/drvs.json
	# jq '.["default"]' .pipelinix/drvs.json
    ;;
    log)
	nix log ./$1
    ;;
    version)
	echo "0.1"
    ;;
    *)
	echo "Immutable and Composable Pipeline"
	echo
	echo "Usage: pipelinix command [options] [arguments]"
	echo
	echo "Commands:"
	echo
	echo "init:           Scaffold pipeline.yaml inside the current directory."
	echo "run:            Run pipeline"
	echo "show:           Show derivations of pipeline"
	echo "version:        Display pipeline version"
	echo
	exit 1
esac

''
