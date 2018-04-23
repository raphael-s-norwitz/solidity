		(returnlll
			(seq
				;; Euclid's GCD algorithm
				(set 'a 1071)
				(set 'b 462)
				(while @b
					[a]:(raw @b [b]:(mod @a @b)))
				(return a 0x20)))
