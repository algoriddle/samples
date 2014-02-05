let palindrome p =
    let s = p.ToString()
    let r = s.ToCharArray()
    System.Array.Reverse(r)
    s = new string(r)

seq { for x in {100..999} do
        for y in {x..999} do
            yield (x, y, x * y) }
    |> Seq.filter (fun (x, y, p) -> palindrome p)
    |> Seq.maxBy (fun (_, _, p) -> p)
    |> fun (x, y, p) -> printf "%i %i %i" x y p
