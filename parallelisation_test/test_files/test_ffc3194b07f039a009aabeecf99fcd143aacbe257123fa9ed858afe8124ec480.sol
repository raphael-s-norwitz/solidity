		(returnlll
			(seq
				(when (= (div (calldataload 0x00) (exp 2 224)) 0xab5ed150)
					(return "one"))
				(when (= (div (calldataload 0x00) (exp 2 224)) 0xee784123)
					(return "two"))
				(return "three")))
