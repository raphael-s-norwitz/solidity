		(returnlll
			(seq
				(set 'x 1)
				(set 'y 2)
				;; this should equal to 3
				(set 'z (add (get 'x) (get 'y)))
				;; overwriting it here
				(set 'y 4)
				;; each variable has a 32 byte slot, starting from memory location 0x80
				;; variable addresses can also be retrieved by x or (ref 'x)
				(set 'k (add (add (ref 'x) (ref 'y)) z))
				(return (add (add (get 'x) (add (get 'y) (get 'z))) (get 'k)))))
