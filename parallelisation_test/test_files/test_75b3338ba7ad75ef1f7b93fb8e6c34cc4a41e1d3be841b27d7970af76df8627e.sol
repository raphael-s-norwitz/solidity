		(returnlll
			(seq
				(when (= (calldatasize) 0) (return 1))
				(when (!= (calldatasize) 0) (return 2))))
