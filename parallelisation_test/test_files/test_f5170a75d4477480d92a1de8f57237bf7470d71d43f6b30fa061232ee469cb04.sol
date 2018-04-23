		(returnlll
			(seq
				(def 'input (calldataload 0x04))
				;; Calculates width in bytes of utf-8 characters.
				(return
					(switch
						(< input 0x80) 1
						(< input 0xE0) 2
						(< input 0xF0) 3
						(< input 0xF8) 4
						(< input 0xFC) 5
						6))))
