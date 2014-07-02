
module Queue : sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val push : 'a t -> 'a -> 'a t
  val shift : 'a t -> 'a t * 'a
end = struct
  type 'a t = 'a list * 'a list

  let empty = ([], [])

  let is_empty = function
    | ([], []) -> true
    | _ -> false

  let push (front, back) x = 
    (x :: front, back)

  let rec shift queue =
    match queue with
    | (front, []) -> shift ([], List.rev front)
    | (front, hd :: tl) -> ((front, tl), hd)
end
