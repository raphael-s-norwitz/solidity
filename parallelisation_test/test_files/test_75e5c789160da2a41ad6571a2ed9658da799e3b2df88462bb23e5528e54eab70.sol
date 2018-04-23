		(returnlll
			(seq
				(mstore8 0x00 (+ 160 22))
				(mstore8 0x01 (- 223 41))
				(mstore8 0x02 (* 33 2))
				(mstore8 0x03 (/ 10 2))
				(mstore8 0x04 (% 67 2))
				(mstore8 0x05 (& 15 8))
				(mstore8 0x06 (| 18 8))
				(mstore8 0x07 (^ 26 6))
				(return 0x00 0x20)))
