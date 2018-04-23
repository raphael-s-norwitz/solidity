			(returnlll
				(seq
					(call allgas
						(create 42 (returnlll (return (balance (address)))))
						0 0 0 0x00 0x20)
					(return 0x00 0x20)))
