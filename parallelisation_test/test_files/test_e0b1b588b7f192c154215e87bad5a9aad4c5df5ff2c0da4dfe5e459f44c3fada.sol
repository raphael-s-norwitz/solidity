		(returnlll
			(seq
				(when (= 0 (calldatasize))
					(seq
						(mstore 0x20 1)
						(mstore 0x40 2)
						(return (msg 1000 (address) 42 0x20 0x40))))
				(when (= 3 (+ (calldataload 0x00) (calldataload 0x20)))
					(return (callvalue)))))

