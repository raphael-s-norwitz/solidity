		(returnlll
			(seq
				(def 'x 1)
				(def 'y () { (def 'x (+ x 2)) })
				(y)
				(return x)))
