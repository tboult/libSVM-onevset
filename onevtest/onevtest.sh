#!/bin/bash
	cd onevtest
        for x in 0 1 2 3 ; do for y in 5 6 7 ; do  echo build iris-m-$x-$y;  ../svm-train -s $y -t $x iris.tr iris-m-$x-$y >> onevset.train; ../svm-predict  iris.t iris-m-$x-$y junk >> onevset.test  ;done ; done
	diff -w onevset.train onevset.train.out
	diff -w onevset.test onevset.test.out
        echo "test complete"

