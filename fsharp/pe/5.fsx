let rec gcd a b = 
    if b = 0 then a
    else gcd b (a % b)

{2..20}
    |> Seq.fold (fun acc x -> acc / (gcd acc x) * x) 1
    |> printf "%i"
