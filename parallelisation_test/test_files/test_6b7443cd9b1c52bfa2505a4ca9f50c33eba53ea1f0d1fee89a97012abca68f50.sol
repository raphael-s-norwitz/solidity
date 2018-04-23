		(returnlll
			(seq
				(when (= 0 (calldatasize))
					(seq
						(mstore 0x40 1)
						(def 'outsize 0x20)
						(return (msg 1000 (address) 42 0x40 0x20 outsize) outsize)))
				(when (= 1 (calldataload 0x00))
					(return (callvalue)))))
