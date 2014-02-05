let divisible ds n = Seq.exists (fun d -> n % d = 0) ds

[1..999]
    |> Seq.filter (divisible [3; 5])  
    |> Seq.sum 
    |> printf "%i\n"


let sum n = n * (n + 1) / 2

printf "%i\n" (sum (999 / 3) * 3 + sum (999 / 5) * 5 - sum (999 / 15) * 15)