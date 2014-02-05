// must not be divisible by 2
let rec factor (n : int64) d =
    if d * d > n 
    then 
        n
    else 
        match System.Math.DivRem(n, d) with
        | (q, 0L) -> factor q d
        | _ -> factor n (d + 2L)

printf "%i" (factor 600851475143L 3L)
