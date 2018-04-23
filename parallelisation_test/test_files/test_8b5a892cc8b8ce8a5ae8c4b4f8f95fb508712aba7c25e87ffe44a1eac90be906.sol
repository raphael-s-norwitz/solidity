		(returnlll
			(seq
				(def 'input (calldataload 0x04))
				;; Calculates width in bytes of utf-8 characters.
				(return
					(if (< input 0x80) 1
						(if (< input 0xE0) 2
							(if (< input 0xF0) 3
								(if (< input 0xF8) 4
									(if (< input 0xFC) 5
										6))))))))

