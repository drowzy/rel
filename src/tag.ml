open Core.Std
open Core_extended.Std

type t = {
  major: int;
  minor: int;
  patch: int;
  ext: string
}
type ext =
  | Pre of string
  | Regular
type version =
  | Major of ext
  | Minor of ext
  | Patch of ext

let from_string str =
  match String.split_on_chars ~on: ['.'; '-';] str with
  | [major; minor; patch;] -> {
      major = int_of_string major;
      minor = int_of_string minor;
      patch = int_of_string patch;
      ext = ""
    }
  | [major; minor; patch; ext;] -> {
      major = int_of_string major;
      minor = int_of_string minor;
      patch = int_of_string patch;
      ext = ext
    }
  | _ -> { major = 0; minor = 0; patch = 0; ext = ""}

let to_string {major; minor; patch; ext;} =
  let t_ext = if not (String.is_empty ext)
    then Printf.sprintf "-%s" ext
    else "" in
  Printf.sprintf "%d.%d.%d" major minor patch ^ t_ext

let ext_to_string = function
  | Pre s -> s
  | Regular -> ""

let list_tags () =
  let curr = match Shell.run_one ~expect:[0;128] "git" ["describe"; "--abbrev=0"] with
  | None -> "0.0.0"
  | Some tag -> tag
  in
  from_string curr

let bump ver tag =
  match ver with
  | Patch p -> let ext = ext_to_string p in
    { tag with patch = tag.patch + 1; ext}
  | Minor p -> let ext = ext_to_string p in
    { tag with minor = tag.minor + 1; patch = 0; ext; }
  | Major p -> let ext = ext_to_string p in
    { major = tag.major + 1; minor = 0; patch = 0; ext; }

let git_tag tag message =
  let opts = ["tag"; "-a"; to_string tag; "-m " ^ message;] in
  match Shell.run_one ~expect:[0] "git" opts with
    _ -> tag
