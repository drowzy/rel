open Core.Std
open Core_extended.Std

type tag = {
  major: int;
  minor: int;
  patch: int;
}
type sem_ver = | Major | Minor | Patch

let tag_to_string {major; minor; patch;} =
  Printf.sprintf "%d.%d.%d" major minor patch

let list_tags () =
  Shell.run_one ~expect:[0;128] "git" ["describe"; "--abbrev=0"]

let git_tag message tag =
  let opts = ["tag"; "-a"; tag_to_string tag; "-m "; message;] in
  match Shell.run_one ~expect:[0] "git" opts with
    _ -> tag

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

let next_version ver message =
  let current_version = list_tags ()
                        |> determine_current_version
                        |> create_tag
  in
  tick_version ver current_version
  |> git_tag message

let major =
  Command.basic ~summary:"Major version"
    Command.Spec.(
      empty
      +> flag "-m" (optional string) ~doc:"string message"
    )
    (fun message () ->
       match message with
       | Some buf -> printf "message %s" buf
       | None -> printf "version bump"
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
       | None -> printf "version bump"
    )

let patch =
  Command.basic ~summary:"Patch version"
    Command.Spec.(
      empty
      +> flag "-m" (optional string) ~doc:"string message"
    )
    (fun message () ->
       match message with
       | Some buf -> next_version Patch buf
                     |> tag_to_string
                     |> printf "%s created"
       | None -> next_version Patch "version bump"
                 |> tag_to_string
                 |> printf "%s created"
    )

let command =
  Command.group ~summary: "Creates a semantic git tag" [ "major", major; "minor", minor; "patch", patch ]

let () = Command.run command
