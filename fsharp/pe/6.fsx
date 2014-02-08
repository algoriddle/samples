let square x = x * x

let range = {1..100}

printf "%i" (square (Seq.sum range) - Seq.sumBy square range)