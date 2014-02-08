let primes = 
    let rec next (n, ps) = 
        if ps 
            |> List.rev  // OMG!
            |> Seq.takeWhile (fun p -> p * p <= n) 
            |> Seq.exists (fun p -> n % p = 0)
            |> not
        then 
            Some (n, (n + 1, n::ps))
        else 
            next (n + 1, ps)
    Seq.unfold next (2, [])

primes 
    |> Seq.nth 10000 
    |> printf "%i" 
