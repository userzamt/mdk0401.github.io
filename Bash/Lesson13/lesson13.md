# Урок 13. Язык обработки данных awk

[На главную](/mdk0401.github.io)

![awk](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/The-AWK-Programming-Language.svg/350px-The-AWK-Programming-Language.svg.png)

**Awk** — утилита и реализованный в ней сценарный язык для построчного разбора и редактирования текстового потока. `Awk` развила идеи таких утилит, как `Sed` и `Grep`, поэтому многое в ней похоже на них. 

**AWK** - утилита предназначенная для простых, механических и вычислительных манипуляций над данными. Довольно несложные операции часто необходимо выполнить над целыми пакетами файлов, а писать для этого программу на одном из стандартных языков программирования является утомительным и, как правило, не очень простым делом. Оптимальное решение проблемы - использование специальной утилиты `AWK`, включающей в себя не громоздкий и удобный **язык программирования**, позволяющий решать задачи обработки данных с помощью коротких программ, состоящих из двух-трех строк.

Утилита `AWK` изначально объединяла свойства утилит UNIX - `sed` и `grep`. В дальнейшем ее возможности значительно расширились. 

> [!NOTE]
> Утилита `AWK` была создана в 1977г, американскими авторами: **Alfred V.Aho**, **Brian W.Kernighan** и **Peter J.Weinberger**. Подробное описание всех возможностей утилиты AWK для UNIX дает их издание: *The AWK Programming Language, 1988*.

По сравнению с `Sed`, язык `Awk` больше похож на Си и имеет множество его возможностей, такие как:

+ объявление переменных и массивов с динамической типизацией;
+ арифметические операции;
+ ветвления и циклы;
+ объявление функций и использование библиотеки встроенных функций.

`Awk` по сути является продолжателем `Sed`, привнося в процесс поточной обработки такие улучшения, как:

+ автоматическая разбивка входящего фрагмента на поля, причем с возможностью смены разделителя на ходу;
+ улучшенный процедурный язык программирования с переменными, циклами, функциями и условиями;
множество встроенных переменных, облегчающих парсинг входящего фрагмента;
+ возможность передавать переменные из вызова в программу.

`Awk` часто применяется для
+ поиска в текстовых файлах характерных фрагментов;
+ анализа текста и сбора статистики;
+ написания простых утилит редактирования, когда использование компилируемого языка не рационально.

> [!WARNING]
> `Awk` разрабатывался много лет, поэтому на практике вы можете столкнуться с разными реализациями. 

## Варианты вызова
В простом случае вызов `Awk` выглядит так

```bash
awk опции 'условие {действие}' <файл 1> <файл 2>... <файл N>
```

В данном вызове `Awk` будет выполнять свою программу над каждым переданным файлом по порядку.


Обрабатываемый текст может передаваться утилите и другими средствами командной оболочки:

```bash
# По конвейеру в STDIN
echo "hello" | awk '{print}'

# Направление строки в STDIN (первый вариант)
awk '{print}' <<< "hello"

# Направление строк в STDIN через Here-docs (второй вариант)
awk '{print}' <<EOF
hello
EOF

# Перенаправив поток через дескриптор
awk '{print}' < file.txt
# аналогично
awk '{print}' file.txt
```

> [!IMPORTANT]
> Если `Awk` не получает в качестве ввода файл, то он читает просто `STDIN`, который обычно связывается с клавиатурой (интерактивный режим).


```bash
awk опции 'условие {действие} условие {действие}
```

`Awk` воспринимает поступающие к нему данные в виде набора записей. Записи представляют собой наборы полей. Упрощенно, если не учитывать возможности настройки `awk` и говорить о некоем вполне обычном тексте, строки которого разделены символами перевода строки, запись — это строка. Поле — это слово в строке.

Наиболее часто используемые ключи(опции) командной строки `awk`:

+ `-F fs` — позволяет указать символ-разделитель для полей в записи.
+ `-f file` — указывает имя файла, из которого нужно прочесть `awk`-скрипт.
+ `-v var=value` — позволяет объявить переменную и задать её значение по умолчанию, которое будет использовать `awk`.
+ `-mf N` — задаёт максимальное число полей для обработки в файле данных.
+ `-mr N` — задаёт максимальный размер записи в файле данных.
+ `-W keyword` — позволяет задать режим совместимости или уровень выдачи предупреждений `awk`.

## Чтение awk-скриптов из командной строки
Скрипты `awk`, которые можно писать прямо в командной строке, оформляются в виде текстов команд, заключённых в **фигурные скобки**. Кроме того, так как `awk` предполагает, что скрипт представляет собой текстовую строку, его нужно заключить в **одинарные кавычки**:

```bash
awk '{print "Welcome to awk command tutorial"}'
```

Запустим эту команду… И ничего не произойдёт Дело тут в том, что мы, при вызове awk, не указали файл с данными. В подобной ситуации awk ожидает поступления данных из `STDIN`. Поэтому выполнение такой команды не приводит к немедленно наблюдаемым эффектам, но это не значит, что awk не работает — он ждёт входных данных из `STDIN`.

Если теперь ввести что-нибудь в консоль и нажать `Enter`, `awk` обработает введённые данные с помощью скрипта, заданного при его запуске. `Awk` обрабатывает текст из потока ввода построчно, этим он похож на `sed`. В данном случае `awk` ничего не делает с данными, он лишь, в ответ на каждую новую полученную им строку, выводит на экран текст, заданный в команде `print`.

> [!WARNING]
> Для того, чтобы завершить работу `awk`, нужно передать ему символ конца файла (EOF, End-of-File). Сделать это можно, воспользовавшись сочетанием клавиш `CTRL + D`.

## Позиционные переменные
Одна из основных функций `awk` заключается в возможности манипулировать данными в текстовых файлах. Делается это путём автоматического назначения переменной каждому элементу в строке. По умолчанию `awk` назначает следующие переменные каждому полю данных, обнаруженному им в записи:

+ `$0` — представляет всю строку текста (запись).
+ `$1` — первое поле.
+ `$2` — второе поле.
+ `$n` — n-ное поле.

Поля выделяются из текста с использованием символа-разделителя. По умолчанию — это **пробельные символы** вроде пробела или символа табуляции.

```bash
awk '{print $1}' access.log
```

Здесь использована переменная $1, которая позволяет получить доступ к первому полю каждой строки и вывести его на экран.

Иногда в некоторых файлах в качестве разделителей полей используется что-то, отличающееся от пробелов или символов табуляции. Выше упоминался ключ `awk -F`, который позволяет задать необходимый для обработки конкретного файла разделитель:

```bash
awk -F: '{print $1}' /etc/passwd
awk -F : '{print $1}' /etc/passwd
awk -F ';' '{print $1}' /etc/passwd
```

Эта команда выводит первые элементы строк(логины), содержащихся в файле `/etc/passwd`. Так как в этом файле в качестве разделителей используются двоеточия, именно этот символ был передан `awk` после ключа `-F`.

## Использование нескольких команд
Вызов `awk` с одной командой обработки текста — подход очень ограниченный. `Awk` позволяет обрабатывать данные с использованием многострочных скриптов. Для того, чтобы передать `awk` многострочную команду при вызове его из консоли, нужно разделить её части точкой с запятой:

```bash
echo "My name is Tom" | awk '{$4="Adam"; print $0}'
```

В данном примере первая команда записывает новое значение в переменную `$4`, а вторая выводит на экран всю строку.

```bash
awk '{count+=1;print count, $3, $7}' access.log
awk '{count+=1;print(count, $3, $7)}' access.log
```

> [!NOTE]
> `print` является встроенной функцией в `awk`

## Чтение скрипта awk из файла
`Awk` позволяет хранить скрипты в файлах и ссылаться на них, используя ключ `-f`. 

```awk
{print "Логин", $1, "домашний каталог" $6}
```

Вызовем `awk`, указав этот файл в качестве источника команд:

```bash
awk -F: -f scriptawk /etc/passwd
```

Выводится имена пользователей, которые попадают в переменную `$1`, и их домашние директории, которые попадают в `$6`. Обратите внимание на то, что файл скрипта задают с помощью ключа `-f`, а разделитель полей, двоеточие в нашем случае, с помощью ключа `-F`.

> [!NOTE]
> Можно воспользоваться командой `column -t` для более наглядного отображения
>  `awk -F: -f scriptawk /etc/passwd | column -t`

В файле скрипта может содержаться множество команд, при этом каждую из них достаточно записывать с новой строки, ставить после каждой точку с запятой не требуется.

```awk
{
text = " has a  home directory at "
print $1 text $6
}
```

Тут мы храним текст, используемый при выводе данных, полученных из каждой строки обрабатываемого файла, в переменной, и используем эту переменную в команде `print`. 

`Awk` может быть вызвана как исполняемая **Awk-программа**. Для этого нужно создать простой файл и в первой его строке указать *башенг с awk-утилитой* в качестве интерпретатора следующим образом

```awk
#!/bin/awk -f

# Код на языке Awk
BEGIN { print "Hello, World!" }
```

После этого нужно сделать файл исполняемым и запускать программу обычным методом.

`Awk` в нормальной ситуации возвращает 0, если программа не прервалась по оператору `exit` с иным кодом возврата. В случае ошибки возвращается 1. В случае фатальной ошибки возвращается 2.

## Выполнение команд до и после обработки данных
Любая `Awk` программа строится по меньшей мере из одного основного блока, в который помещаются инструкции, применяемые к каждому фрагменту, если блок не имеет шаблона.

Помимо основного блока, есть еще два необязательных: `BEGIN` и `END`. 

Блок `BEGIN` исполняется один раз в начале обработки каждого текста. Часто туда закладывается начальная инициализация, которая актуальна на время обработки всего текста. Например, если бы задачей `Awk` было разбиение полей фрагмента по колонкам, то в блок `BEGIN` логично поместить процедуру вывода шапки для этих колонок.

Второй блок `END` хранит инструкции, которые выполняются один раз после обработки всех фрагментов текста. Туда можно закладывать подсчеты всевозможных статистик, очистку окружения от мусора, отправку сообщений по почте о завершении процесса обработки текста и прочее.

```bash
awk -F ';' 'BEGIN {print "Тип Наименование Рейтинг"} {print $2, $1, $4} END {print "Type Name Rate"}' supplier_k_import.csv
```

> [!NOTE]
> Описание для полей в файле `supplier_k_import.csv` - Наименование поставщика; Тип поставщика; ИНН; Рейтинг качества; Дата начала работы с поставщиком

## Переменные
В языке `awk` выделяют две группы переменных:

+ Предопределенные(встроенные)
+ Декларированные в программе.

### Встроенные переменные
Исходные значения предопределенных переменных устанавливаются интерпретатором `awk` в процессе запуска и выполнения `awk-программы`.

К предопределенным относятся:

| Переменная | Описание|
| :--: | :-- |
| NR | номер текущей строки |
| NF | число полей в текущей строке |
| RS | разделитель строк на вводе |
| FS | разделитель полей на вводе |
| ORS | разделитель строк на выводе |
| OFS | разделитель полей на выводе |
| OFMT | формат вывода чиcла |
| FILENAME | имя входного файла |

```bash
awk 'BEGIN{FS=":"; OFS="_"} {print $1, $7}' /etc/passwd
```
Переменная `FIELDWIDTHS` позволяет читать записи без использования символа-разделителя полей.

В некоторых случаях, вместо использования разделителя полей, данные в пределах записей расположены в колонках постоянной ширины. В подобных случаях необходимо задать переменную `FIELDWIDTHS` таким образом, чтобы её содержимое соответствовало особенностям представления данных.

При установленной переменной `FIELDWIDTHS` `awk` будет игнорировать переменную `FS` и находить поля данных в соответствии со сведениями об их ширине, заданными в `FIELDWIDTHS`.

```bash
awk '{FIELDWIDTHS="56 24 68 15"} {print $2, $4}' ENGINE02.TXT
```

```bash
echo "2222 555555" | awk '{FIELDWIDTHC="4 6"} {print "Серия", $1, "Номер", $2}'
```

### Встроенные переменные: сведения о данных и об окружении
Существуют переменные, которые предоставляют сведения о данных и об окружении, в котором работает `awk`:

+ `ARGC` — количество аргументов командной строки.
+ `ARGV` — массив с аргументами командной строки.
+ `ARGIND` — индекс текущего обрабатываемого файла в массиве ARGV.
+ `ENVIRON` — ассоциативный массив с переменными окружения и их значениями.
+ `ERRNO` — код системной ошибки, которая может возникнуть при чтении или закрытии входных файлов.
+ `FILENAME` — имя входного файла с данными.
+ `FNR` — номер текущей записи в файле данных.
+ `IGNORECASE` — если эта переменная установлена в ненулевое значение, при обработке игнорируется регистр символов.
+ `NF` — общее число полей данных в текущей записи.
+ `NR` — общее число обработанных записей.

```bash
awk 'BEGIN{print ENVIRON["HOME"]}'
```

Переменные среды можно использовать и без обращения к `ENVIRON`. 

```bash
echo | awk -v home=$HOME '{print "My home is " home}'
```

Переменная `NF` позволяет обращаться к последнему полю данных в записи, не зная его точной позиции

```bash
awk 'BEGIN{FS=":"; OFS="+"} {print $1,$NF}' /etc/passwd
```

### Пользовательские переменные
Как и любые другие языки программирования, awk позволяет программисту объявлять переменные. Имена переменных могут включать в себя буквы, цифры, символы подчёркивания. Однако, они не могут начинаться с цифры. 

```bash
awk 'BEGIN{str="Hello world"} {print str}'
```

```awk
{
    # awk script
    BEGIN {count=0}

    count+=1
    print count
}
```

> [!NOTE]
> В программах `Awk` допустимы однострочные комментарии, начинающиеся с символа решетки `#`. 

### Типы данных и переменные
Как уже было сказано, синтаксис языка `Awk` был в основном заимствован у языка Си, но с динамической типизацией переменных, а также урезанным количеством встроенных типов данных.

Строго говоря, в `Awk` всего два типа данных: **числовой** и **строковый**. Чтобы определить переменную, достаточно инициализировать ее некоторым значением.

```awk
number = 10     # числовая переменная
string = "abc"  # строковая переменная
```

> [!NOTE]
> Первые реализации могли хранить строковые переменные только как восьмибитные ASCII-символы. На текущий момент проблем с кодировками нет в современных системах.

Кроме простых переменных, в `Awk` есть еще массивы, которые порождаются через их инициализацию:

```awk
array[0] = "element"
```

Элементы массивов можно адресовать по строковым ключам (ассоциативные массивы), например

```awk
fruits["banana"] = 60
```

## Условный оператор
`Awk` поддерживает стандартный во многих языках программирования формат условного оператора `if-then-else`. Однострочный вариант оператора представляет собой ключевое слово `if`, за которым, в скобках, записывают проверяемое выражение, а затем — команду, которую нужно выполнить, если выражение истинно.

```bash
awk -F ';' '{if ($4 > 70) {print}}' supplier_k_import.csv
awk -F ';' '{if ($4 > 70) print}' supplier_k_import.csv
```

Как уже было сказано, условный оператор awk может содержать блок `else`

```bash
awk -F ';' '{if ($4 > 70) {printf "\033[31m%s %s\033[0m\n", $2, toupper($1)} else print $2, $1}' supplier_k_import.csv
```

> [!WARNING]
> Данные конструкции лучше всего писать в отдельно скрипте

## Циклы
В `Awk` есть три типа циклов:

+ for
+ while
+ do-while

а также два управляющих для циклов слова:

+ break
+ continue

> [!NOTE]
> Синтаксис аналогичен языкам Си, C#, JS

> [!WARNING]
> Целесообразнее использовать циклы в отдельным `awk-скриптах`

## Встроенные функции
[Встроенные функции](https://www.gnu.org/software/gawk/manual/html_node/Built_002din.html#Built_002din)

При работе с `awk` программисту доступны встроенные функции. В частности, это математические и строковые функции, функции для работы со временем. 

+ cos(x) — косинус x (x выражено в радианах).
+ sin(x) — синус x.
+ exp(x) — экспоненциальная функция.
+ int(x) — возвращает целую часть аргумента.
+ log(x) — натуральный логарифм.
+ rand() — возвращает случайное число с плавающей запятой в диапазоне 0 — 1.
+ sqrt(x) — квадратный корень из x.
+ print(строка) - вывод чего либо в стандартный поток вывода;
+ printf(строка) - форматированный вывод в стандартный поток вывода;
+ system(команда) - выполняет команду в системе;
+ length(строка) - возвращает длину строки;
+ substr(строка, старт, количество) - обрезает строку и возвращает результат;
+ tolower(строка) - переводит строку в нижний регистр;
+ toupper(строка) - переводить строку в верхний регистр.

> [!WARNING]
> Функций намного больше см. ссылку выше

```bash
awk -F ';' '{print tolower($2), toupper($1), sqrt($4)}' supplier_k_i
```

## Пользовательские функции
В `Awk` можно объявлять собственные функции, чтобы группировать повторяющийся однотипный код. Определения функций могут располагаться где угодно между блоками, причем функция может быть объявлена после ее первого вызова, так как `Awk` читает программу целиком прежде чем ее исполнить. 

```awk
function <имя функции>(<список аргументов>)
	<тело функции>
```

Правила объявления имен функций аналогичны правилам именования переменных. Список аргументов функции представляет собой передаваемые локальные для функции переменные, перечисленные через запятую.

```awk
function func1(arg1, arg2) {
        print arg1,arg2
}
function func2() {
        return 0
}
{
        # Аргументы для любой функции не обязательны
        func1()
        func1("Hello")
        func1("Hello ", "World!")
        
        # Возвращаемые результаты обычно как то анализируются
        if (func2()) {
                print "Do something"
        } else {
                print "Do nothing"
        }
        
        print func3()
}
# Функция может объявляться после первого обращения к ней
function func3() {
        # Функция без проблем может возвращать строки, как результат
        return "Hello!"
}
```


## Форматированная печать с помощью printf
В сложных ситуациях может понадобится форматированный вывод, в котором все аспекты контролируются так называемой форматной строкой. Для тех, кто когда-либо писал программы на Си и использовал стандартную библиотеку ввода/вывода, правила написания форматной строки будут знакомы.

```awk
printf "<форматная строка>", <элемент 1> ..., <элемент N>
```

Форматная строка объясняет `printf` структуру выводимой строки с помощью специальных символов, называемых **форматами**, которые впоследствии **заменяются на передаваемые элементы**. Каждому формату сопоставляется ровно один элемент слева направо со второго аргумента.

Любой формат начинается с символа `%`, после которого минимально идет буква, называющая тип данных для данного формата. Все форматы в неизменном виде перекочевали из стандартной библиотеки Си, но в урезанном виде, так как в `Awk` нет такого многообразия типов данных.

Ниже перечислены возможные форматы:

+ `%c` (char) – единичный символ.
+ `%s` (string) – используется для строк.
+ `%d` или `%i` (decimal) – знаковое десятичное целое число.
+ `%u`(unsigned decimal) – беззнаковое целое десятичное число. Беззнаковое означает, что в двоичном представлении числа старший бит не тратится на хранение знака, благодаря чему удваивается диапазон представления положительных чисел.
+ `%o` (octal) – число в восьмеричной системе счисления. Для этого формата, кроме конвертации, будет подписываться ведущий ноль.
+ `%x` или `%X` (hexdecimal) – число в щестнадцатеричной системе счисления, причем для `%X` символы A-F выводятся в верхнем регистре. Для этого формата, кроме конвертации, будет подписываться префикс 0x.
+ `%e` или `%E` (exponential) – вещественное число будет представлено в экспоненциальной форме, причем для `%E` символ экспоненты будет записан в верхнем регистре.
+ `%f` или `%g` или `%G` (float) – число с плавающей запятой. Формат `%g` позволяет `Awk` выбрать для числа наиболее компактную запись между `%f` или `%e`. Вариант %G соответственно делает выбор между `%f` и `%E`.

```bash
awk -F ';' 'BEGIN{count=0}{count+=1; printf "%d Название фирмы %s\t%s\tРейтинг %f\n", count, $2, $1, sqrt($4)}' supplier_k_import.csv
```

