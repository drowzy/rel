open Core.Std

type t

type ext =
  | Pre of string
  | Regular
type version =
  | Major of ext
  | Minor of ext
  | Patch of ext

(** Bump tag version *)
val bump : version -> t -> t

(** converts the tag to a string *)
val to_string : t -> string

val ext_to_string : ext -> string

(** writes a git tag in cwd with message and tag *)
val git_tag : t -> string -> t

(** converts from a string to a tag *)
val from_string : string -> t

(** list tags in the cwd *)
val list_tags : unit -> t
