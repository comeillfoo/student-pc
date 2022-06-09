# student-pc (student-pascal-compiler)

## Задание. Вариант 7.

### Правила в форме Бэкуса-Наура.

```
<Программа>             ::= <Объявление переменных> <Описание вычислений>

<Описание вычислений>   ::= "Begin" <Список операторов> "End" "."

<Объявление переменных> ::= "Var" <Список переменных>

<Список переменных>     ::= <Идент> ";"
| <Идент> "," <Список переменных>
| <Идент> ";" <Список переменных>

<Список операторов>     ::= <Оператор>
| <Оператор> <Список операторов>

<Оператор>              ::= <Присваивание>
| <Сложный оператор>
| <Составной оператор> 

<Составной оператор>    ::= Begin <Список операторов> End

<Присваивание>          ::= <Идент> "=" <Выражение> ";"

<Выражение>             ::= <Ун. оп.> <Подвыражение>
| <Подвыражение>

<Подвыражение>          ::= "(" <Выражение> ")"
| <Операнд>
| <Подвыражение> <Бин. оп.> <Подвыражение>

<Ун. оп.>                ::= "-" | "not"

<Бин. оп.>               ::= "-" | "+" | "*" | "/" | "**" | ">" | "<" | "=="

<Операнд>               ::= <Идент> | <Const>

<Сложный оператор>      ::= "IF" "(" <Выражение> ")" <Оператор>
| "IF" "(" <Выражение> ")" <Оператор> "ELSE" <Оператор>
| <Оператор цикла>

<Оператор цикла>        ::= "REPEAT" <Список операторов> "UNTIL" <Выражение>

<Идент>                 ::= <Буква> <Идент> | <Буква>

<Const>                 ::= <Цифра> <Const> | <Цифра>
```

### Комментарии.
```
Для вариантов 1, 4, 7, 12 комментарий в стиле С++ однострочный
//   ----- Комментарий ------
```

---

## 1. Написание лексера и реализация правил грамматики

### 1.1. Лексер

Статус: написан и генерирует токены.
TODO:   избавиться от варнингов -> настроить приоритет.

### 1.2. Реализация правил грамматики
#### Список реализованных правил

| Статус             | Название из варианта      | Название в `spc.scan.y`       |
| ------------------ | ------------------------- | ----------------------------- |
| :heavy_check_mark: | `<Программа>`             | `program`                     |
| :heavy_check_mark: | `<Описание вычислений>`   | `description_of_calculations` |
| :heavy_check_mark: | `<Объявление переменных>` | `variables_declaration`       |
| :heavy_check_mark: | `<Список переменных>`     | `variables_list`              |
| :heavy_check_mark: | `<Список операторов>`     | `statements_list`             |
| :heavy_check_mark: | `<Оператор>`              | `statement`                   |
| :heavy_check_mark: | `<Составной оператор>`    | `composed_statement`          |
| :heavy_check_mark: | `<Присваивание>`          | `assignment`                  |
| :heavy_check_mark: | `<Выражение>`             | `expression`                  |
| :heavy_check_mark: | `<Подвыражение>`          | `subexpression`               |
| :heavy_check_mark: | `<Ун. оп.>`               | `unop`                        |
| :heavy_check_mark: | `<Бин. оп.>`              | `binop`                       |
| :heavy_check_mark: | `<Операнд>`               | `operand`                     |
| :heavy_check_mark: | `<Сложный оператор>`      | `branch_statement`            |
| :heavy_check_mark: | `<Оператор цикла>`        | `loop_statement`              |
| :heavy_check_mark: | `<Идент>`                 | `ident`                       |
| :heavy_check_mark: | `<Const>`                 | `const`                       |

---

## 2. Инструкция к использованию.

### 1. Компиляция:
    make all
### 2. Список коман:
    ./spc --help
    SYNOPSYS
        spc [-v] [-f <input file>] [-o <output file>]
    DESCRIPTION
    -h, --help
    shows this help message and exits
    -f, --file
    specifies the input file path, default: stdin
    -o, --out
    specifies the output file path, default: a.out
    -a, --ast
    if option presents then ast tree prints in stderr
    -v, --verbose
    enables extra output

### 3. Вывод ast
    ./spc --ast < programs/fact8.pas
    <program:0x5567574baf00[ child: 0x5567574babd0 ]>
    <statements-list:0x5567574babd0[ current: 0x5567574b95b0, next: 0x5567574badf0 ]>
    <expression:0x5567574b95b0[ left: 0x5567574b94a0, oper: =, right: 0x5567574b9390 ]>
    <identifier:0x5567574b94a0[ name: n ]>
    <constant:0x5567574b9390[ value: 5 ]>
    <expression:0x5567574b9900[ left: 0x5567574b97f0, oper: =, right: 0x5567574b96e0 ]>
    <identifier:0x5567574b97f0[ name: result ]>
    <constant:0x5567574b96e0[ value: 1 ]>
    <repeat-until:0x5567574baac0[ test: 0x5567574ba9b0, body: 0x5567574ba550 ]>
    <statements-list:0x5567574ba550[ current: 0x5567574b9eb0, next: 0x5567574ba660 ]>
    <expression:0x5567574b9eb0[ left: 0x5567574b9da0, oper: =, right: 0x5567574b9c90 ]>
    <identifier:0x5567574b9da0[ name: result ]>
    <expression:0x5567574b9c90[ left: 0x5567574b9a50, oper: *, right: 0x5567574b9b80 ]>
    <identifier:0x5567574b9a50[ name: result ]>
    <identifier:0x5567574b9b80[ name: n ]>
    <expression:0x5567574ba440[ left: 0x5567574ba330, oper: =, right: 0x5567574ba220 ]>
    <identifier:0x5567574ba330[ name: n ]>
    <expression:0x5567574ba220[ left: 0x5567574ba000, oper: -, right: 0x5567574ba110 ]>
    <identifier:0x5567574ba000[ name: n ]>
    <constant:0x5567574ba110[ value: 1 ]>
    <expression:0x5567574ba9b0[ left: 0x5567574ba790, oper: ==, right: 0x5567574ba8a0 ]>
    <identifier:0x5567574ba790[ name: n ]>
    <constant:0x5567574ba8a0[ value: 1 ]>

### 4. TAC
    ./spc -o b.out < programs/fact8.pas
    Код будет находиться в файле b.out


