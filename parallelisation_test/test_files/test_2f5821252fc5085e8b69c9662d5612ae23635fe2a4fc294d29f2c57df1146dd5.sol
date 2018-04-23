			(returnlll
				(seq
					(call allgas
						(create (returnlll (return 42)))
						0 0 0 0x00 0x20)
					(return 0x00 0x20)))
