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

let msg_flag = Command.Spec.(empty +> flag "-m" (optional string) ~doc:"string message")

let major =
  Command.basic ~summary:"Major version"
    msg_flag
    (fun message () ->
       next_version Tag.Major message
       |> printf "%s created"
    )

let minor =
  Command.basic ~summary:"Minor version"
    msg_flag
    (fun message () ->
       next_version Tag.Minor message
       |> printf "%s created"
    )

let patch =
  Command.basic ~summary:"Patch version"
    msg_flag
    (fun message () ->
       next_version Tag.Patch message
       |> printf "%s created"
    )

let command =
  Command.group ~summary: "Creates a semantic git tag" [ "major", major; "minor", minor; "patch", patch ]

let () = Command.run command
