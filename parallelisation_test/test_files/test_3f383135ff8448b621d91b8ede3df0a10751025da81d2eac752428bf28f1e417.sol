			(returnlll
				(seq
					(lit 0x20 "abcdefghijklmnopqrstuvwxyzABCDEF")
					(lit 0x40 "GHIJKLMNOPQRSTUVWXYZ0123456789?!")
					(sha256 0x20 0x40)
					(return 0x00 0x20)))
