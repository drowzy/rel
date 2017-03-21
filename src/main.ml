open Core.Std
open Core_extended.Std

type tag = {
  major: int;
  minor: int;
  patch: int;
}
type sem_ver =
  | Major | Minor | Patch

let list_tags () =
  Shell.run_one ~expect:[0;128] "git" ["describe"; "--abbrev=0"]

let create_tag sep_tag =
  match List.map ~f:int_of_string (String.split ~on: '.' sep_tag) with
  | [major; minor; patch] -> { major = major; minor = minor; patch = patch; }
  | [] | _ -> { major = 0; minor = 0; patch = 0; }

let determine_current_version tag =
  match tag with
  | None -> "0.0.0"
  | Some t -> t

let tick_version ver t =
  match ver with
  | Patch -> { t with patch = t.patch + 1; }
  | Minor -> { t with minor = t.minor + 1; patch = 0; }
  | Major -> { major = t.major + 1; minor = 0; patch = 0; }

let next_version ver =
  let current_version = list_tags ()
                        |> determine_current_version
                        |> create_tag
  in
  tick_version ver current_version

let major =
  Command.basic ~summary:"Major version"
    Command.Spec.(
      empty
      +> flag "-m" (optional string) ~doc:"string message"
    )
    (fun message () ->
       match message with
       | Some buf -> printf "message %s" buf
       | None -> printf "no message"
    )

let minor =
  Command.basic ~summary:"Minor version"
    Command.Spec.(
      empty
      +> flag "-m" (optional string) ~doc:"string message"
    )
    (fun message () ->
       match message with
       | Some buf -> printf "message %s" buf
       | None -> printf "no message"
    )

let patch =
  Command.basic ~summary:"Patch version"
    Command.Spec.(
      empty
      +> flag "-m" (optional string) ~doc:"string message"
    )
    (fun message () ->
       match message with
       | Some buf -> printf "message %s" buf
       | None -> printf "no message"
    )

let command =
  Command.group ~summary: "Creates a semantic git tag" [ "major", major; "minor", minor; "patch", patch ]

let () = Command.run command
