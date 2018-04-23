		(returnlll
			(seq
				(set 'x (alloc 1))
				(mstore8 @x 42)    ; ASCII '*'
				(return @x 0x20)))
