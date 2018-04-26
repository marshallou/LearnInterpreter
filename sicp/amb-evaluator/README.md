# amb Evaluator

## First impression on Success and Fail

  From the basic code of amb evaluator, I only get a general idea about sucess and fail. It seems now the evaluating expression is "Nondeterministic", meaning evaluating expression can sometimes success and sometimes fail.

  When sucess, we need to call "sucess" method. When "fail", we need to call "fail" to make an another choice to continue evaluating.

  But how to achieve that and where to fetch the choice and when to resume execution are things still confuse me.

## Success Invariant

  Thinkingn further. The key point is "invariant". In order to understand "success" and "fail", we need to understand the "invariant" that the "success" and "fail" wants to keep.

  At first, I have no clue about what "invariant" they want to keep, until I saw the code which anlyze "if".
  
```
(define (analyze-if exp)
    (let ((pproc (analyze (if-predicate exp)))
          (cproc (analyze (if-consequent exp)))
          (aproc (analyze (if-alternative exp))))

    (lambda (env succeed fail)
        (pproc env
               ;; success continuation for evaluating the predicate
               ;; to obtain pred-value
               (lambda (pred-value fail2)
                       (if (true? pred-value)
 		       (cproc env succeed fail2)
		       (aproc env succeed fail2)))

	       ;; failure continuation for evaluating the predicate
 	       fail))))
```
  Analyzing "if" can be decomposed into three parts. Analyze if-predicate, analyze if-consequent and analyze if-alternative. If we look at the relationship between analyze "if" and analyze if-predicate to understand the invariant.

  Personally, I feel the mechanism is quite similar to delegate design pattern in a function programming way. Here is the story. "If" expression's job is to dispatch the control flow to different branch based on the value of if-prediate expression, but it does not know the value of if-prediate while analyzing. So "if" told "if-prediate": "I will give you a function called 'success', after you evaluate the value, you pass the value to this 'success' function. The 'success' function will do rest of the work'. In CPS(Continuous Passing Style), the if-predicate is called hole of evaluating expression.

  From here we know the invariant for 'success' is: "When evaluating an expression, if part of sub expression are not able to be analyzed at this time, calling success later with evaluated sub expression value will produce the value of whole expression."

  But currently, I still do not know the invariant for 'fail'. I can imagine fail will undo the side effect. But how it automatically makes an alternative choice and resumes the execution is still confusing me.


## Fail Invariant
  I am still not able to figure out the invariant of 'fail'. I can only describe what I found so far. 
  Since we know the concept of 'hole' in CPS, the 'hole' can be chained. 'fail' is defined along the chaining process while analyzing subexpression. When triggered, it will evaluate all previous chained subexpressions with alternative choice.

  Thus 'fail' is defined by chained subexpression, fail is called in 'amb' (for most cases, in require)