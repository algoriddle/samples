let rec last_two = function
  | [] | [_] -> None
  | [x; y] -> Some (x, y)
  | _::tl -> last_two tl
;;

last_two [ "a" ; "b" ; "c" ; "d" ];;

last_two [ "a" ];;
