let rec gcd a b = 
    if b = 0 then a
    else gcd b (a % b)

let lcm a b = a / (gcd a b) * b

{2..20}
    |> Seq.fold lcm 1
    |> printf "%i"
