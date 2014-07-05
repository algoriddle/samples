let rec last = function
  | [] -> None
  | [x] -> Some x
  | _::tl -> last tl
;;

last [ "a" ; "b" ; "c" ; "d" ];;
(* Some "d" *)

last [];;
(* None *)
