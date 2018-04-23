		(returnlll
			(seq
				(mstore8 0x00 (! (< 53 87)))
				(mstore8 0x01 (! (>= 42 73)))
				(mstore8 0x02 (~ 0x7f))
				(mstore8 0x03 (~ 0xaa))
				(return 0x00 0x20)))
