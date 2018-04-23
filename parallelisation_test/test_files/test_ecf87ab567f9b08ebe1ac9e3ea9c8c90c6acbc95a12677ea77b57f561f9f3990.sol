		(returnlll
			(seq
				(perm 'x) (x (+ 1 x))
				(perm 'y) (y (+ 10 y))
				(when (= 2 permcount)
					(return (+ x y)))))
