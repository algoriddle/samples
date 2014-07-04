open Core.Std

type t = (string * int) list

let empty = []

let to_list t = t

let touch t s =
  let count =
    match List.Assoc.find t s with
    | None -> 0
    | Some x -> x
  in
  List.Assoc.add t s (count + 1)