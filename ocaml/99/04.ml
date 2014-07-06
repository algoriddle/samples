let length l =
  let rec length_acc acc = function
    | [] -> acc
    | _::tl -> length_acc (acc + 1) tl
  in
  length_acc 0 l
;;

length [ "a" ; "b" ; "c"];;

length [];;
