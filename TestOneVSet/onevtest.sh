#!/bin/bash
	cd TestOneVSet
        pushd ..; make; popd;
	echo "if all goes well you'll see 10 runs of Training then the phrase **Test Complete**"
        rm -f onevset.train onevset.test
        for x in 0 1 2 3 ; do for y in 5 6 7 ; do   ../svm-train -s $y -t $x iris.tr iris-m-$x-$y >> onevset.train; ../svm-predict  iris.t iris-m-$x-$y junk >> onevset.test  ;done ; done
	diff -w onevset.train onevset.train.out
	diff -w onevset.test onevset.test.out
        rm -f iris-m* junk
        rm -f onevset.train onevset.test
        echo "**Test Complete**"


