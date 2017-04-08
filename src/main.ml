open Core.Std
open Core_kernel.Fn

let next_version version message =
  let msg = match message with
    | Some buf -> buf
    | None -> "version bump"
  in
  Tag.list_tags ()
  |> Tag.bump version
  |> flip Tag.git_tag msg
  |> Tag.to_string

let common =
  Command.Spec.(
    empty
    +> flag "-m" (optional string) ~doc:"string message"
  )

let ext_cmd =
  Command.Spec.(
      empty
      +> flag "-pre" (optional string) ~doc: "prefix for preversion"
      ++ common
  )
let run version = (fun message () ->
    next_version version message
    |> printf "%s created\n"
  )

let deter_pre pre =
  match pre with
    | Some buf -> Tag.Pre buf
    | None -> Tag.Regular

let major = Command.basic ~summary:"Major version" common (run (Tag.Major Tag.Regular))
let minor = Command.basic ~summary:"Minor version" common (run (Tag.Minor Tag.Regular))
let patch = Command.basic ~summary:"Patch version" common (run (Tag.Patch Tag.Regular))

let pre_major =
  Command.basic
    ~summary:"Pre-major version"
    ext_cmd
    (fun pre message () -> run (Tag.Major (deter_pre pre)) message ())

let pre_minor =
  Command.basic
    ~summary:"Pre-minor version"
    ext_cmd
    (fun pre message () -> run (Tag.Minor (deter_pre pre)) message ())

let pre_patch =
  Command.basic
    ~summary:"Pre-patch version"
    ext_cmd
    (fun pre message () -> run (Tag.Patch (deter_pre pre)) message ())

let command =
  Command.group ~summary: "Creates a semantic git tag"
    [ "major", major;
      "minor", minor;
      "patch", patch;
      "premajor", pre_major;
      "preminor", pre_minor;
      "prepatch", pre_patch;
    ]

let () = Command.run command
