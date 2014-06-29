open Core.Std

module Log :
sig
  type t

  val logon : string -> user : string -> t
  val message : string -> message : string -> t
  val messages_for_user : string -> t list -> string list
end = struct
  type logon = { user : string }
  type message = { message : string }

  type payload =  
      Logon of logon
    | Message of message

  type t = {
    session_id : string;
    time : Time.t;
    payload : payload }

  let logon session_id ~user = 
    { session_id; time = Time.now (); payload = Logon { user } }

  let message session_id ~message = 
    { session_id; time = Time.now (); payload = Message { message } }

  let messages_for_user user entries = 
    let (messages, _) = List.fold entries ~init:([], String.Set.empty) ~f:(fun ((messages, session_ids) as acc) { session_id; time; payload } ->
        match payload with
        | Logon { user = logon_user } ->
          if logon_user = user then
            (messages, Set.add session_ids session_id)
          else
            acc
        | Message { message } ->
          if Set.mem session_ids session_id then
            ((Time.to_string time ^ " " ^ message)::messages, session_ids)
          else
            acc
      ) in 
    List.rev messages
end

let () =
  [ Log.logon "x" ~user:"a"; 
    Log.message "x" ~message:"ha"; 
    Log.message "y" ~message:"hi";
    Log.logon "z" ~user:"b";
    Log.logon "w" ~user:"a";
    Log.message "z" ~message:"ho";
    Log.message "w" ~message:"hu" ]
  |> Log.messages_for_user "a"
  |> String.concat ~sep:"\n"          
  |> printf "%s" 
