			(returnlll
				(seq
					(when (= 0 (calldatasize))
						(return (msg (address) 0xff)))
					(return 42)))
