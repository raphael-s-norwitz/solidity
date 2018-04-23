		(returnlll
			(seq
				(mstore 0x40 0)     ; Set initial MSIZE to 0x60
				(return (alloc 1))))
