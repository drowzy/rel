open Core.Std
open Core_extended.Std

type t = { major: int; minor: int; patch: int;}
type version = Major | Minor | Patch

let from_string str =
  match List.map ~f:int_of_string (String.split ~on: '.' str) with
  | [major; minor; patch] -> { major = major; minor = minor; patch = patch; }
  | _ -> { major = 0; minor = 0; patch = 0; }

let to_string {major; minor; patch;} =
  Printf.sprintf "%d.%d.%d" major minor patch

let list_tags () =
  let curr = match Shell.run_one ~expect:[0;128] "git" ["describe"; "--abbrev=0"] with
  | None -> "0.0.0"
  | Some tag -> tag
  in
  from_string curr

let bump ver tag =
  match ver with
  | Patch -> { tag with patch = tag.patch + 1; }
  | Minor -> { tag with minor = tag.minor + 1; patch = 0; }
  | Major -> { major = tag.major + 1; minor = 0; patch = 0; }

let git_tag tag message =
  let opts = ["tag"; "-a"; to_string tag; "-m " ^ message;] in
  match Shell.run_one ~expect:[0] "git" opts with
    _ -> tag
