		(returnlll
			(seq
				(def 'zeroarg () (seq (mstore 0 0x1234) (return 0 32)))
				(zeroarg)))
