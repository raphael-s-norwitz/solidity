		(returnlll
			(seq
				(mstore 0x00 0) ; reserve space for the result of the alloc
				(mstore 0x00 (alloc (calldataload 0x04)))
				(return (- (msize) (mload 0x00)))))
