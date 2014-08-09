open Core.Std
open Async.Std

let () =
  Reader.file_contents "cat.ml"
  >>| printf "%s"
  >>> fun () -> shutdown 0

let () =
  never_returns (Scheduler.go ())
