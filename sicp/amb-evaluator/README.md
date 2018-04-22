# amb Evaluator

## First impression on Success and Fail

  From the basic code of amb evaluator, I only get a general idea about sucess and fail. It seems now the evaluating expression is "Nondeterministic", meaning evaluating expression can sometimes success and sometimes fail.

  When sucess, we need to call "sucess" method. When "fail", we need to call "fail" to make an another choice to continue evaluating.

  But how to achieve that and where to fetch the choice and when to resume execution are things still confuse me.

## Invariant

  Thinkingn further. The key point is "invariant". In order to understand "success" and "fail", we need to understand the "invariant" that the "success" and "fail" wants to keep.

  At first, I have no clue about what "invariant" they want to keep, until I saw the code which anlyze "if".
  
  For expressions like self-evaluating, quote, variable and lambda, are predestined to be sucess. They serve as base case of this recursive evaluating process. Since those are expressions that when evaluating, are predestined to be success, we know the process is shown below:
- evaluate the expression
- get the evaluated value
- call sucess with the value

  Now we can take a look at the process of analysing if.

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
  Analyzing "if" can be decomposed into three parts. Analyze if-predicate, analyze if-consequent and analyze if-alternative. Now if we look at the relationship between analyze "if" and analyze if-predicate, we can understand the invariant.

  Personally, I feel the mechanism is quite similar to delegate design pattern in a function programming way. Here is the story. "If" expression's job is to dispatch based on the value of if-prediate expression, but it does not know the value of if-prediate while analyzing. So "if" told "if-prediate": "I will give you a function called 'success', after you evaluate the value, you pass the value to this 'success' function. The 'success' function will do dispatch for you'.

  From here we know the invariant for 'success' is: "in recursive evaluating process, the parent expression should pass a 'sccess' function to unevaluated child expression, where child expression call it with evaluated value, it will generate the evaluated result of parent expression.

  But currently, I still do not know the invariant for 'fail'. I can imagine fail will undo the side effect. But how does it automatically make an alternative choice and resume execution is still confusing me.

