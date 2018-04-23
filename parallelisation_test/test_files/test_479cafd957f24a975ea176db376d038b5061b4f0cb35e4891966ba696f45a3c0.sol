		(returnlll
			(seq
				(unless (!= (calldatasize) 0) (return 1))
				(unless (= (calldatasize) 0) (return 2))))
