# VSCode + clang-format. Установка стиля форматирования для VSCode

## Prompt:
_Расскажи на примере любой конфигурации как добавить и использовать указанный стиль в VSCode._

### **Как добавить и использовать стиль `clang-format` в VSCode (на примере LLVM Style)**

В этом руководстве мы настроим `clang-format` в **Visual Studio Code** для автоматического форматирования кода в стиле **LLVM** (как в `CppFormatExample.cpp`).  

---

## **1. Установка необходимых инструментов**  
### **1.1. Установка `clang-format`**  
- **Linux (Debian/Ubuntu):**  
  ```sh
  sudo apt install clang-format
  ```
- **macOS (Homebrew):**  
  ```sh
  brew install clang-format
  ```
- **Windows (Chocolatey):**  
  ```sh
  choco install llvm
  ```
  (или скачайте с [официального сайта LLVM](https://llvm.org/)).  

### **1.2. Установка расширения в VSCode**
1. Откройте **VSCode**.  
2. Перейдите в **Extensions** (`Ctrl+Shift+X`).  
3. Найдите и установите:  
   - **C/C++** (от Microsoft)  
   - **Clang-Format** (от xaver)  

---

## **2. Настройка стиля форматирования**  
### **2.1. Создаём файл `.clang-format`**  
1. В корне проекта создайте файл `.clang-format`.  
2. Вставьте конфигурацию для **LLVM Style** (из прошлого ответа):  
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

## **3. Настройка VSCode для автоматического форматирования**
1. Откройте **настройки VSCode** (`Ctrl+,`).  
2. Введите `clang-format` в поиске.  
3. Убедитесь, что включены:  
   - **Editor: Format On Save** (`editor.formatOnSave`)  
   - **C_Cpp: Clang_format_fallback Style** (`LLVM`)  
   - **C_Cpp: Clang_format_path** (укажите путь к `clang-format`, например, `/usr/bin/clang-format` в Linux).  

   ![VSCode Clang-Format Settings](https://i.imgur.com/XYZABC.png)  

4. (Опционально) Можно добавить **горячую клавишу** для форматирования:  
   - Откройте `File > Preferences > Keyboard Shortcuts`.  
   - Найдите `Format Document` и назначьте сочетание (например, `Ctrl+Shift+F`).  

---

## **4. Проверка работы**
1. Откройте любой `.cpp` файл.  
2. Нажмите **`Ctrl+S`** (если включено автоформатирование) или **`Ctrl+Shift+F`** (если вручную).  
3. Код должен автоматически отформатироваться в стиле **LLVM** (фигурные скобки на той же строке, отступы 2 пробела и т. д.).  

---

### **5. Возможные проблемы и решения**
❌ **`clang-format not found`**  
- Убедитесь, что `clang-format` установлен и путь в настройках VSCode верный.  

❌ **Форматирование не применяется**  
- Проверьте `.clang-format` в корне проекта.  
- Попробуйте перезапустить VSCode.  

✅ **Готово! Теперь код автоматически форматируется в выбранном стиле.** 🎉
