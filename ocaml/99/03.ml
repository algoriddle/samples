let rec at k = function
  | [] -> None
  | hd::tl -> 
    if k = 1 then Some hd
    else at (k - 1) tl
;;

at 3 [ "a" ; "b"; "c"; "d"; "e" ];;

at 3 [ "a" ];;
