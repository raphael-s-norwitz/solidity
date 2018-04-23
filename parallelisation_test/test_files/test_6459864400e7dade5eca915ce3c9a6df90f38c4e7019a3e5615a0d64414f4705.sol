			(returnlll
				(seq
					(when (= 0 (calldatasize))
						(return (msg (address) 42 0xff)))
					(return (callvalue))))
