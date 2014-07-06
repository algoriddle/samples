let is_palindrome l =
  l = List.rev l
;;

is_palindrome [ "x" ; "a" ; "m" ; "a" ; "x" ];;

not (is_palindrome [ "a" ; "b" ]);;
