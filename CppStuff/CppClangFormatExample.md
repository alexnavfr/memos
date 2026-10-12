# Примеры конфигураций для `clang-format`

## Prompt:
_В предложенных файлах с фрагментами кода на языке C++ с различным форматированием. Проанализируй оба файла и подготовь файлы которые могут быть использованы для clang-format. Если возможно распознай стиль форматирования в каждом файле_
Для анализа был предоставлены 2 файла `CppFormatExample.md`(LLVM style) и `CppFormatExampleMine.md`(этот формат наиболее привычен мне).

Проанализировав оба файла, я определил стили форматирования и подготовил соответствующие конфигурации для `clang-format`.

### **1. Анализ стилей**

#### **Файл `CppFormatExampleMine.cpp`**
- **Стиль**: GNU-подобный стиль с элементами пользовательского форматирования.
- **Характеристики**:
  - Фигурные скобки на новой строке для классов, функций, пространств имён и блоков.
  - Отступы в 4 пробела.
  - Пробелы вокруг операторов.
  - Пустые строки между логическими блоками.
  - Выравнивание параметров и аргументов в многострочных конструкциях.

#### **Файл `CppFormatExample.cpp`**
- **Стиль**: LLVM (как указано в комментарии).
- **Характеристики**:
  - Фигурные скобки на той же строке (K&R-стиль).
  - Отступы в 2 пробела (характерно для LLVM).
  - Компактное расположение кода.
  - Пробелы вокруг операторов.
  - Пробелы после запятых в списках.

---

### **2. Конфигурации для `clang-format`**

#### **Для `CppFormatExampleMine.cpp` (GNU-подобный стиль)**
```yaml
BasedOnStyle: GNU
Language: Cpp
AccessModifierOffset: -4
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: false
AlignConsecutiveDeclarations: false
AlignEscapedNewlines: Left
AlignOperands: Align
AlignTrailingComments: true
AllowAllParametersOfDeclarationOnNextLine: false
AllowShortBlocksOnASingleLine: false
AllowShortCaseLabelsOnASingleLine: false
AllowShortFunctionsOnASingleLine: None
AllowShortIfStatementsOnASingleLine: false
AllowShortLoopsOnASingleLine: false
AlwaysBreakAfterDefinitionReturnType: None
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: Yes
BinPackArguments: false
BinPackParameters: false
BraceWrapping:
  AfterClass: true
  AfterControlStatement: true
  AfterEnum: true
  AfterFunction: true
  AfterNamespace: true
  AfterObjCDeclaration: true
  AfterStruct: true
  AfterUnion: true
  BeforeCatch: true
  BeforeElse: true
  IndentBraces: false
BreakBeforeBinaryOperators: None
BreakBeforeBraces: Custom
BreakBeforeTernaryOperators: true
BreakConstructorInitializers: BeforeColon
ColumnLimit: 80
CompactNamespaces: false
ConstructorInitializerAllOnOneLineOrOnePerLine: true
ContinuationIndentWidth: 4
Cpp11BracedListStyle: true
DerivePointerAlignment: false
FixNamespaceComments: true
IndentCaseLabels: true
IndentWidth: 4
KeepEmptyLinesAtTheStartOfBlocks: true
MaxEmptyLinesToKeep: 2
PointerAlignment: Left
SpaceAfterCStyleCast: true
SpaceAfterTemplateKeyword: true
SpaceBeforeAssignmentOperators: true
SpaceBeforeParens: ControlStatements
SpaceInEmptyParentheses: false
SpacesInAngles: false
SpacesInContainerLiterals: true
SpacesInCStyleCastParentheses: false
SpacesInParentheses: false
SpacesInSquareBrackets: false
TabWidth: 4
UseTab: Never
```

#### **Для `CppFormatExample.cpp` (LLVM Style)**
```yaml
BasedOnStyle: LLVM
Language: Cpp
AccessModifierOffset: -2
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: false
AlignConsecutiveDeclarations: false
AlignEscapedNewlines: Left
AlignOperands: Align
AlignTrailingComments: true
AllowAllParametersOfDeclarationOnNextLine: true
AllowShortBlocksOnASingleLine: true
AllowShortCaseLabelsOnASingleLine: true
AllowShortFunctionsOnASingleLine: Inline
AllowShortIfStatementsOnASingleLine: true
AllowShortLoopsOnASingleLine: true
AlwaysBreakAfterDefinitionReturnType: None
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: Yes
BinPackArguments: true
BinPackParameters: true
BraceWrapping:
  AfterClass: false
  AfterControlStatement: false
  AfterEnum: false
  AfterFunction: false
  AfterNamespace: false
  AfterObjCDeclaration: false
  AfterStruct: false
  AfterUnion: false
  BeforeCatch: false
  BeforeElse: false
  IndentBraces: false
BreakBeforeBinaryOperators: None
BreakBeforeBraces: Attach
BreakBeforeTernaryOperators: false
BreakConstructorInitializers: BeforeComma
ColumnLimit: 80
CompactNamespaces: false
ConstructorInitializerAllOnOneLineOrOnePerLine: false
ContinuationIndentWidth: 2
Cpp11BracedListStyle: true
DerivePointerAlignment: false
FixNamespaceComments: true
IndentCaseLabels: false
IndentWidth: 2
KeepEmptyLinesAtTheStartOfBlocks: false
MaxEmptyLinesToKeep: 1
PointerAlignment: Right
SpaceAfterCStyleCast: false
SpaceAfterTemplateKeyword: true
SpaceBeforeAssignmentOperators: true
SpaceBeforeParens: ControlStatements
SpaceInEmptyParentheses: false
SpacesInAngles: false
SpacesInContainerLiterals: true
SpacesInCStyleCastParentheses: false
SpacesInParentheses: false
SpacesInSquareBrackets: false
TabWidth: 2
UseTab: Never
```

---

### **3. Рекомендации по использованию**
1. **Для применения стиля `GNU`** (как в `CppFormatExampleMine.cpp`):
   ```sh
   clang-format -style=file -i CppFormatExampleMine.cpp
   ```
   (предварительно сохранив конфигурацию в `.clang-format`).

2. **Для применения стиля `LLVM`** (как в `CppFormatExample.cpp`):
   ```sh
   clang-format -style=file -i CppFormatExample.cpp
   ```

Эти конфигурации позволят автоматически форматировать код в соответствии с выбранным стилем.
