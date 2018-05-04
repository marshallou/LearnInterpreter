# Learn Interpreter

## 1.SICP's Basic version of Metacircular evaluator of scheme

The basic version of evaluator is under [/evaluator](https://github.com/marshallou/learn-interpreter/tree/master/sicp/evaluator)

### 1.1 Environment setup

#### 1.1.1 Emacs and MIT scheme environment setup
- https://stackoverflow.com/questions/4259894/how-to-run-scheme-with-emacs
- download MIT scheme mac version
- rename the app name to be "mit-scheme.app" to remove ":" which prevents the resource path to be imported
- create a symlink to mit-scheme ```sudo ln -s /Applications/mit-scheme.app/Contents/Resources/mit-scheme /usr/local/bin/mit-scheme```
- config emacs to use mit-scheme when requesting to start sheme interpreter
  - In Emacs type M-x customize-group then type scheme. Scroll down a bit and find the Scheme program name field. Change it to your Scheme implementation command, namely, mit-scheme.
  - For MIT Scheme, you also need to set the MITSCHEME-LIBRARY-PATH variable, so add this to your .emacs ```(setenv "MITSCHEME_LIBRARY_PATH" "/Applications/mit-scheme.app/Contents/Resources")```
- type M-x run-scheme to start scheme interpeter

#### 1.1.2 Start evaluator
open "start.scm" file and C-c C-l to load it into scheme interpreter

### 1.2 Implement the Metacircular evaluator of scheme.
   Metacircular evaluator and parsing: normal interpreter should also contains parsing step. Parse means to translate the evaluated expression into an object which implementing language can understand. Since we are building metacircular evaluator, the evaluated expression passed into evaluator is always quoted list. Thus, the parsing step can be skipped.

### 1.3 "evaluator.scm" describes high level idea about how evaluator works.

#### 1.3.1 Abstaction
we create an file called "representations.scm" by writting constructors, getters and setters of different expression type. "representations.scm" established an abstraction between evaluating process and detail implementation of the expression. So our evaluator does not depend on implementation of different expression type.

#### 1.3.2 the evaluator contains two core functions: eval and evaluator-apply
I use the name "evaluator-apply" rather than "apply" is because "evaluator_data_structure.scm" use scheme underlying "apply" procedure to execute primitive procedure. Override original "apply" will create a lot of mess.

#### 1.3.3 eval:
- eval is the process of dispatch. When evaluating an expression, we need to understand what is the type of expression and then evaluate. Then based on the type, we perform proper actions on the expression type.
- Note: Currently we use dispatch strategy. Later after reading following chapters, I need to modify it to be data directed pattern, meaning "eval" will perform depends on the expression type automatically, kind similar to the concept of polymorphism in OOP.

#### 1.3.4 evaluator-apply:
- apply is used to evaluate precedure.
- lambda and procedure: The most complex area in this evaluator is how to deal with function. The function definition is represented by lambda which contains two parts: parameters and body. Evaluating lambda creats procedure. The difference between lambda and procedure is that the procedure has an environment pointer. The pointer points to environment where lambda is evaluated.
- lexical scope and dynamic scope:
  - Scheme is lexical scope is because of previous reason. Namely, procedure's environment pointer always points to where the procedure is "defined", namely, where the lambda is evaluated. When procedure is invoked (applied), we will create a new frame (environment) to bind the parameters of the procedure. Thus, when procedure is referring a free variable, it looks up from environment where procedure is defined.
  - dynamic scope: Instead of extending environment where we define the procedure, if we extend environment where we invoke the procedure, it becomes dynamic scope. When refering free variables, we search all the way of our calling stack.
  - For internal definition, variables defined between are in both calling stack and definition environment.

### 1.4 "representations.scm" contains expression represenations. "evaluator_data_structures.scm" contains representation of environment and procedure

#### 1.4.1 Loading order:
Load "representations.scm" first. Because it contains " tagged-list?" procedure which "evaluator_data_structures.scm" depends on.

#### 1.4.2 As described before, representations of expression type are quoted list. 

#### 1.4.3 primitive procedure and compound procedure:
There are two kinds of procedures: primitive and compound procedures.
  - compound procedure is represented as tagged list "procedure".
  - primitive procedure is represented as tagged list "primitive". It has form as ```('primitive procedure-implementation)```
  - At loading time, we store key/value pairs (key is primitive procedure name, value is tagged list "primitive) in base environment.
    

## 2.SICP's amb version of Metacircular evaluator
  
The amb evaluator version is under /amb-evaluator

### 2.1 analyzed evaluator

The first step of implementing amb evaluator is to transform original evaluator to an analyzed version.

#### 2.1.1 intro of analyzed evaluator

The basic evaluator takes tagged list as input and dispatch based on analyzing tagged list type. The idea of analyzed evaluator is to analyze those tagged list before execution. We transform those tagged list to executable procedures.

#### 2.1.2 implementation
The analyzed evaluator has two steps in evaluating process. First, it takes an expression and analyze it to produce a lambda. Second, it invokes the lambda function by passing the environment as its argument.

#### 2.1.3 performance gain of analyzed evaluator
The analyze step itself is recursive. Personally, There is not much information gain for basic expressions like if, variable, quote, definition, asignment, application. Because both basic evaluator and analyzed evaluator will have those analyze steps. It is just that analyzed evaluator does it in analyzing phase. What really makes difference is analyzing lambda expression. Because analyzing lambda will recursively analyze the lambda body which is something we won't do for basic evaluator. 

This means if we invoke the lambda many times, we can reuse the analyzed body for many times which improves the efficiency.

### 2.2 amb evaluator

amb evaluator is an evaluator which supports "amb" special form expression.

Details can be found: [amb-evaluator](https://github.com/marshallou/learn-interpreter/blob/master/sicp/amb-evaluator/README.md)

## 3.SICP's logical programming

logical programming is programming style which is different from now programming style. Normal programming gives step by step procedure to interpretor/compiler and interpretor will execute those instructions to compute result. But logical programming does not care "how" the result is computed. It just describes what it compute.

### 3.1 how it works
logical programming will give a list of rules to interpretor to initialize the system. Having the rules, interpretor is able to apply mathematical deduction to compute the result. We call the question/problem the logical programming trys to solve "query".

Since it is interpretor, we know that the process of solving the problem consiting of two parts: eval and apply.

### 3.2 eval and apply
There are two kinds of rules stored in interpretor:

- The basic rule which we call it assertion and it is the end of recursive induction. Similar to the concept of primitive types of a language.
- The compound rule which is defined by other rules. Similar to the concept of procedure of a language.

When given a "query" (expression), the interpretor will first eval the "query". This is done by a process called "pattern match" or "unification". It go through all the rules stored in interpretor and check whether the query "pattern matches" the rule. If it matches the basic rule, we return the matched pattern variable in a data structure called frame. The problem solved.

If it "pattern matches" a compound rule, there will be an "apply" process. We unify the pattern variable in "query" and "rule conclusion" and treat the body of the rule as a new query. We recursively eval the new query until we the query reduced to a basic rule.

### 3.3 details
Details can be found: [amb-evaluator](https://github.com/marshallou/learn-interpreter/blob/master/sicp/logical-evaluator/README.md)