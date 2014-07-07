open Core.Std

module Memo : sig
  val memoize : ('a -> 'b) -> 'a -> 'b
end = struct
  type 'a result = Value of 'a | Exception of exn

  let memoize f =
    let hash_table = Hashtbl.Poly.create () in
    (fun x -> 
      match Hashtbl.find hash_table x with
      | Some Value y -> printf "cache\n"; y
      | Some Exception e -> printf "cache\n"; raise e
      | None ->
        let y = 
          try f x with
          | e -> 
            Hashtbl.add_exn hash_table ~key:x ~data:(Exception e);
            raise e
        in
        Hashtbl.add_exn hash_table ~key:x ~data:(Value y);
        y
    )
end
;;

let a x = 
  if x > 10
  then x + 1
  else raise (Failure "too small")
;;

let b = Memo.memoize a;;
