		(returnlll
			(seq
				(lit 0x00 "abcdef")
				(asm
					0x06 6 codesize sub 0x20 codecopy
					0x20 0x20 return)))
