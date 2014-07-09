open Core.Std

module Make_interval(
    Endpoint : sig
      type t
      val compare : t -> t -> int

      include Sexpable with type t := t
    end) :

sig
  type t
  type endpoint
  val create : endpoint -> endpoint -> t
  val contains : t -> endpoint -> bool

  include Sexpable with type t := t
end
with type endpoint := Endpoint.t =

struct
  type t = | Interval of Endpoint.t * Endpoint.t
           | Empty
  with sexp

  type endpoint = Endpoint.t

  let create low high =
    if Endpoint.compare low high > 0
    then Empty
    else Interval (low, high)

  let contains t x =
    match t with
    | Empty -> false
    | Interval (low, high) ->
      Endpoint.compare low x <= 0 && Endpoint.compare x high <= 0 
end
;;

module String_interval = Make_interval(String);;

let test1 = String_interval.create "alma" "korte";;
let test2 = String_interval.create "dio" "banan";;

String_interval.contains test1 "szilva";;
String_interval.contains test1 "dinnye";;
String_interval.contains test2 "mogyoro";;

String_interval.sexp_of_t test1;;
String_interval.sexp_of_t test2;;

let test3 =
  Sexp.of_string "(Interval dinnye korte)" 
  |> String_interval.t_of_sexp;;

String_interval.contains test3 "dinnye";;
