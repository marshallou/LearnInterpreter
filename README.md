# Learn Interpreter

## 1.SICP's Metacircular evaluator of scheme

### 1.1 Implement the Metacircular evaluator of scheme.
   Metacircular evaluator and parsing: normal interpreter should also contains parsing step. Parse means to translate the evaluated expression into an object which implementing language can understand. Since we are building metacircular evaluator, the evaluated expression passed into evaluator is always quoted list. Thus, the parsing step can be skipped.

### 1.2 "evaluator.scm" describes high level idea about how evaluator works.

#### 1.2.1 Abstaction
we create an file called "representations.scm" by writting constructors, getters and setters of different expression type. "representations.scm" established an abstraction between evaluating process and detail implementation of the expression. So our evaluator does not depend on implementation of different expression type.

#### 1.2.2 the evaluator contains two core functions: eval and apply

#### 1.2.3 eval:
- eval is the process of dispatch. When evaluating an expression, we need to understand what is the type of expression and then evaluate. Then based on the type, we perform proper actions on the expression type.
- Note: Currently we use dispatch strategy. Later after reading following chapters, I need to modify it to be data directed pattern, meaning "eval" will perform depends on the expression type automatically, kind similar to the concept of polymorphism in OOP.

#### 1.2.4 apply:
- apply is used to evaluate precedure.
- lambda and procedure: The most complex area in this evaluator is how to deal with function. The function definition is represented by lambda which contains two parts: parameters and body. Evaluating lambda creats procedure. The difference between lambda and procedure is that the procedure has an environment pointer. The pointer points to environment where lambda is evaluated.
- lexical scope and dynamic scope:
  - Scheme is lexical scope is because of previous reason. Namely, procedure's environment pointer always points to where the procedure is "defined", namely, where the lambda is evaluated. When procedure is invoked (applied), we will create a new frame (environment) to bind the parameters of the procedure. Thus, when procedure is referring a free variable, it looks up from environment where procedure is defined.
  - dynamic scope: Instead of extending environment where we define the procedure, if we extend environment where we invoke the procedure, it becomes dynamic scope. When refering free variables, we search all the way of our calling stack.
  - For internal definition, variables defined between are in both calling stack and definition environment.

### 1.3 "representations.scm" contains expression represenations. "evaluator_data_structures.scm" contains representation of environment and procedure
- As described before, representations of expression type are quoted list. 
- There are two kinds of procedures: primitive and compound procedures.
  - compound procedure is represented as tagged list "procedure".
  - primitive procedure is represented as tagged list "primitive". It has form as ('primitive procedure-implementation).
  - At loading time, we store key/value pairs (key is primitive procedure name, value is tagged list "primitive) into global environment.
    