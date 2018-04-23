		(returnlll
			(seq
				(for
					{ (set 'i 1) (set 'j 1) } ; INIT
					(<= @i 10)                ; PRED
					[i]:(+ @i 1)              ; POST
					[j]:(* @j @i))            ; BODY
				(return j 0x20)))
