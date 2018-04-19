# Learn Interpreter

## 1.SICP's Basic version of Metacircular evaluator of scheme

The basic version of evaluator is under /evaluator

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

The process of evaluation is to understand the expression type and dispatch based on the type for proper evaluation. "understand the expression type" is actually an analyze process. Although for meta-circular evaluator, there is no need for syntax analyze, as all the expression is represented as tagged list, it is still considered as a step of analyze.

So the idea of analyzed evaluator is to analyze ("understand") those tagged list before execution. We transform those tagged list to executable procedures which can improve the performance.

#### 2.1.2 implementation
The analyzed evaluator has two steps in evaluating process. First, it takes an expression and analyze it to produce a procedure. Second, it takes the procedure generated in first step and invoke it by passing the environment as its argument.

#### 2.1.3 performance gain of analyzed evaluator
The analyze step itself is recursive. There is nothing special when analyze basic expression like if, variable, quote, definition, asignment, application. Personally, I feel the main difference is analyze lambda. Comparing to eval lambda which produce a procedure, analyze lambda will recursively analyze the lambda body. This means when we are in execution phase, the body has already been analyzed.

For other expression like if, variable, quote, analyze evaluator gain little efficiency as analyze step will anyway happen in both version of evaluators. But analyzing lambda really makes a difference, since after defining a procedure, it can be invoked multiple times, expecially for recursive procedures. Once we analyze the body, there is no need for analyze a second time which improves a lot of efficiency.

### 2.2 amb evaluator

amb evaluator is an evaluator which supports "amb" special form expression

