(1, 0) 
    |> Seq.unfold (fun (x, y) -> Some (x + y, (x + y, x))) 
    |> Seq.takeWhile ((>=) 4000000) 
    |> Seq.filter (fun z -> z % 2 = 0)
    |> Seq.sum
    |> printf "%i"