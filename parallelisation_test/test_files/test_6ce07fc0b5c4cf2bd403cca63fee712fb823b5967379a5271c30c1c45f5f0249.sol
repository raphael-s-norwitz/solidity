		(returnlll
			(seq
				(when (= 0 (calldatasize))
					(return (msg 1000 (address) 42 0xff)))
				(return (callvalue))))
