rec {
  isDerivation = value: value.type or null == "derivation";

  runCommandWithLog = pkgs: name: env: exec:
    pkgs.runCommand name env (''
      #pipeline-process
      process_name=${name}
      echo "#pipeline-process: $process_name"
      start_time=`date +%s`
      echo "#$process_name: start: $start_time"
      mkdir -p $out;
      ${exec}
      end_time=`date +%s`
      run_time=$((end_time - start_time))
      echo "#$process_name: end: $end_time"
      echo "#$process_name: run: $run_time"
    '');

  process = pkgs: name: value:
    let loop = v:
          if builtins.isFunction v then arg: loop (v arg)
          else if isDerivation v then v
          else if builtins.isPath v then runCommandWithLog pkgs name {} ''
              FILETYPE=`file -b --mine-type ${v}`
              case $command in
                   application/gzip)
                     tar xfz ${v} -C $out
                   ;;
                   *)
                     ln -s ${v} $out/
              esac
            ''
          else 
            let env = if builtins.isString v then {} else v;
                exec = if builtins.isString v then v else v.exec;
            in runCommandWithLog pkgs name env exec
          ;
    in loop value;

  pipeline = pkgs: processes:
    let self = builtins.mapAttrs (process pkgs) (processes self);
    in self;

  compose = processes:
    let h = builtins.head processes;
        t = builtins.tail processes;
        loop = func:
          if builtins.isFunction func
          then arg: loop (func arg)
          else builtins.foldl' (x: y: y x) func t;
    in loop h;
}
