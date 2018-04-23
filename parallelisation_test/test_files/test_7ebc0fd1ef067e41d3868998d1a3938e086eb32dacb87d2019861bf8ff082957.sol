		(returnlll
			(seq
				(def 'input (calldataload 0x04))
				;; Calculates width in bytes of utf-8 characters.
				(return
					(if (>= input 0x80)
						(if (>= input 0xE0)
							(if (>= input 0xF0)
								(if (>= input 0xF8)
									(if (>= input 0xFC)
										6 5) 4) 3) 2) 1))))

