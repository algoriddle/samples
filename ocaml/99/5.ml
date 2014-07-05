let rev l =
  let rec rev_acc acc = function
    | [] -> acc
    | hd::tl -> rev_acc (hd::acc) tl
  in
  rev_acc [] l
;;

rev ["a" ; "b" ; "c"];;
