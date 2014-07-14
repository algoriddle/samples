open Core.Std

module Queue : sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val push : 'a t -> 'a -> 'a t
  val shift : 'a t -> ('a * 'a t) option
  val fold : 'a t -> init:'b -> f:('b -> 'a -> 'b) -> 'b
  val iter : 'a t -> f:('a -> unit) -> unit

  include Container.S1 with type 'a t := 'a t
end = struct
  type 'a t = 'a list * 'a list

  let empty = ([], [])

  let is_empty = function
    | ([], []) -> true
    | _ -> false

  let push (front, back) x = 
    (x :: front, back)

  let shift (front, back) =
    match back with
    | hd :: tl -> Some (hd, (front, tl))
    | [] -> 
      match List.rev front with
      | [] -> None
      | hd :: tl -> Some (hd, ([], tl))

  let fold (front, back) ~init ~f =
    let acc = List.fold back ~init ~f in
    List.fold_right front ~init:acc ~f:(fun x acc -> f acc x)

  let iter (front, back) ~f = 
      List.iter back ~f;
      List.iter (List.rev front) ~f

  include Container.Make(struct
      type nonrec 'a t = 'a t
      let fold = fold
      let iter = Some iter
    end)

end;;

Queue.shift Queue.empty;;
let test1 = Queue.push Queue.empty "alma";;
let test2 = Queue.push test1 "korte";;
let Some (test3, test4) = Queue.shift test2;;
let Some (test5, test6) = Queue.shift test4;;
let test7 = Queue.shift test6;;
Queue.find test2 ~f:((=) "alma");;
Queue.mem test2 "korte";;
