# after DeepSeek

## Prompt
__

Here's the modified function with the requested changes:

```perl
sub generate_report($$) {
    my ( $href, $out, $corp ) = @_;
    my $job    = $href->{"job"};
    my $report = $href->{"report"};
    print $corp "#=========================================\n";
    print $corp "#            REPORT ${job}                \n";
    print $corp "#=========================================\n";

    #---------------------
    # report
    #---------------------

    foreach my $item (@$report)

    {

        my $id = $item->{"id"};

        my $lref_missing_files = $item->{"missing_files"};

        my $lref_valuing_errors = $item->{"valuing_errors"};

        my $lref_funding_errors = $item->{"funding_errors"};

        my $lref_error_log = $item->{"error_log"};

        my $lref_future_errors = $item->{"future_errors"};

        my $lref_curves_errors = $item->{"curves_errors"};

        print STDOUT "@$lref_valuing_errors"
            . "@$lref_missing_files" . "\n"
            . ${id}
            . "@$lref_valuing_errors"
            . "@$lref_funding_errors";

        print STDOUT @${lref_valuing_errors} . "\n";

        if (@$lref_missing_files
            ||

            @$lref_valuing_errors ||

            @$lref_funding_errors ||

            @$lref_future_errors ||

            @$lref_curves_errors
           )

        {

            print $out "#=========================================\n";

            print $out "#            R ${job}                \n";

            print $out "#=========================================\n";

            print $out
                "\n#-------------------------------------------------------\n";

            print $out
                "# ${id}                                                   \n";

            print $out
                "#-------------------------------------------------------\n";

            print $corp
                "\n#-------------------------------------------------------\n";

            # Get BOOK information for PNL section - FIXED
            my $FilterName = substr( ${id}, 5, 10 );
            # Fixed the SQL query syntax and added proper variable
            my @taskresult = &sqlRequest(
                "SELECT Book FROM Tot WHERE Active=1 AND RT='x' AND fn='$FilterName'");

            print $corp
                "# ${id}                                                   \n";
            
            # Display BOOK value properly
            if (@taskresult && defined $taskresult[0][0]) {
                print $corp "BOOK=$taskresult[0][0]\n";
                print $out "BOOK=$taskresult[0][0]\n";
            } else {
                print $corp "BOOK=Not Found\n";
                print $out "BOOK=Not Found\n";
            }

            print $corp
                "#-------------------------------------------------------\n";

            # Helper function to print limited errors
            sub print_limited_errors {
                my ($fh, $errors_ref, $section_name) = @_;
                my $num_errors = @$errors_ref;
                
                print $fh "#----------------------- $section_name ---------------------------\n";
                
                if ($num_errors > 5) {
                    # Print first 5 errors
                    for my $i (0..4) {
                        next unless defined $errors_ref->[$i];
                        print $fh $errors_ref->[$i];
                    }
                    print $fh "\n... and " . ($num_errors - 5) . " more errors (total: $num_errors)\n";
                } else {
                    print $fh @$errors_ref;
                }
                
                print $fh "#-------------------------------------------------------\n";
            }

            if (@$lref_valuing_errors)

            {

                my $num_errors = @$lref_valuing_errors;    # get the numbers

                print $out
                    "#----------------------- PL ---------------------------\n";

                print $out @$lref_valuing_errors;

                print $out
                    "#-------------------------------------------------------\n";

                # Use the helper function for corp report with limited errors
                print_limited_errors($corp, $lref_valuing_errors, "P&L");

            }

            if (@$lref_future_errors)

            {

                my $num_errors = @$lref_future_errors;    # get the numbers

                print $corp
                    "#---------------------- FUT ------------------------\n";

                # Apply the same 5-error limit to future_errors
                if ($num_errors > 5) {
                    for my $i (0..4) {
                        next unless defined $lref_future_errors->[$i];
                        print $corp $lref_future_errors->[$i];
                    }
                    print $corp "\n... and " . ($num_errors - 5) . " more future errors (total: $num_errors)\n";
                } else {
                    print $corp @$lref_future_errors;
                }

                print $corp
                    "#-------------------------------------------------------\n";

            }

            if (@$lref_funding_errors)

            {

                my $num_errors = @$lref_funding_errors;

                print $out
                    "#---------------------- fun ------------------------\n";

                print $out @$lref_funding_errors;

                print $out
                    "#-------------------------------------------------------\n";

                # Also limit funding_errors in corp report if needed
                print $corp "#---------------------- FUNDING ------------------------\n";
                
                if ($num_errors > 5) {
                    for my $i (0..4) {
                        next unless defined $lref_funding_errors->[$i];
                        print $corp $lref_funding_errors->[$i];
                    }
                    print $corp "\n... and " . ($num_errors - 5) . " more funding errors (total: $num_errors)\n";
                } else {
                    print $corp @$lref_funding_errors;
                }
                
                print $corp "#-------------------------------------------------------\n";

            }

            print $out @$lref_error_log if ( !$g_light );

            my @error_log;

            if ( !$g_light ) {

                my $element = @$lref_error_log;

                while ( $element >= 0 ) {

                    @$lref_error_log[$element] =~ s/(..):(..):(..)\.(...)//;

                    @$lref_error_log[$element] =~ s/(..)\/(..)\/(..)\ //;

                    @$lref_error_log[$element] =~ s/^\ //g;

                    #@error_log = grep ( ! Enumerated Value  not found for Enumeration  , @lref_error_log[$element]   );

                    $element = $element - 1;

                }

                # print $corp @$lref_error_log;

                # print $corp @$error_log;

            }

            if (@$lref_curves_errors)

            {

                my $num_errors = @$lref_curves_errors;

                print $out
                    "#---------------------- cur --------------------------\n";

                print $out @$lref_curves_errors;

                print $out
                    "#-------------------------------------------------------\n";

                print $corp
                    "#---------------------- CUR --------------------------\n";

                print $corp "\n";

                my $element = @$lref_curves_errors;

                while ( $element >= 0 ) {

                    @$lref_curves_errors[$element] =~ s/(..):(..):(..)\.(...)//;

                    @$lref_curves_errors[$element] =~
                        s/(..)\/(..)\/(..)\/(..)//;

                    @$lref_curves_errors[$element] =~ s/^\ //g;

                    $element = $element - 1;

                }

                my $element = @$lref_curves_errors;

                my $curseur = 0;

                my @test = ();

                while ( $curseur < $element ) {

                    if ( @$lref_curves_errors[$curseur] eq
                        @$lref_curves_errors[$curseur + 1] )

                    {

                        $curseur = $curseur + 1;

                    }
                    else {

                        $test[$curseur] = @$lref_curves_errors[$curseur - 1];

                        $curseur = $curseur + 1;

                    }

                }

                # Apply 5-error limit to curves errors
                if (scalar(@test) > 5) {
                    for my $i (0..4) {
                        next unless defined $test[$i];
                        print $corp $test[$i];
                    }
                    print $corp "\n... and " . (scalar(@test) - 5) . " more curve errors (total: " . scalar(@test) . ")\n";
                } else {
                    print $corp @test;
                }

                print $corp
                    "#-------------------------------------------------------\n";

            }

            if (@$lref_missing_files)

            {

                my $num_errors = @$lref_missing_files;

                print $out
                    "\n#------------------ missing files ----------------------\n";

                print $out @$lref_missing_files;

                print $out
                    "#-------------------------------------------------------\n";

                # Uncomment and limit missing files in corp report if needed
                #print $corp "\n#------------------ missing files ----------------------\n";
                #
                #if ($num_errors > 5) {
                #    for my $i (0..4) {
                #        next unless defined $lref_missing_files->[$i];
                #        print $corp $lref_missing_files->[$i];
                #    }
                #    print $corp "\n... and " . ($num_errors - 5) . " more missing files (total: $num_errors)\n";
                #} else {
                #    print $corp @$lref_missing_files;
                #}
                #
                #print $corp "#-------------------------------------------------------\n";

            }

        }

        #print $corp $out;

    }

}
```

**Key changes made:**

1. **Added a helper function `print_limited_errors()`** that limits output to 5 errors and shows a summary message with the total count.

2. **Fixed the BOOK retrieval in the PNL section:**
   - Fixed the SQL query syntax (was using `$fn` incorrectly, now uses `$FilterName`)
   - Added proper error checking with `@taskresult` to ensure the BOOK value exists
   - Added fallback "BOOK=Not Found" message if no value is found

3. **Applied the 5-error limit to all sections** in the corp report:
   - P&L section now uses the helper function
   - FUT section limits to 5 errors
   - FUNDING section limits to 5 errors
   - CUR section limits to 5 errors
   - Missing files section is commented out but can be enabled with the same pattern

4. **Each section now shows** the first 5 errors followed by a message like `... and X more errors (total: Y)`

The full report (`$out`) still contains all errors, while the email body (`$corp`) now has limited error display with proper BOOK information.




## second version

Вот модифицированная функция с подробными комментариями на русском языке:

```perl
sub generate_report($$) {
    my ( $href, $out, $corp ) = @_;
    my $job    = $href->{"job"};
    my $report = $href->{"report"};
    
    # Печатаем заголовок отчета в corp (тело email)
    print $corp "#=========================================\n";
    print $corp "#            ОТЧЕТ ${job}                \n";
    print $corp "#=========================================\n";

    #---------------------
    # Обрабатываем каждый элемент отчета
    #---------------------

    foreach my $item (@$report)

    {

        my $id = $item->{"id"};

        my $lref_missing_files = $item->{"missing_files"};      # отсутствующие файлы

        my $lref_valuing_errors = $item->{"valuing_errors"};    # ошибки оценки (P&L)

        my $lref_funding_errors = $item->{"funding_errors"};    # ошибки финансирования

        my $lref_error_log = $item->{"error_log"};              # лог ошибок

        my $lref_future_errors = $item->{"future_errors"};      # ошибки future

        my $lref_curves_errors = $item->{"curves_errors"};      # ошибки кривых

        # Отладочный вывод в STDOUT
        print STDOUT "@$lref_valuing_errors"
            . "@$lref_missing_files" . "\n"
            . ${id}
            . "@$lref_valuing_errors"
            . "@$lref_funding_errors";

        print STDOUT @${lref_valuing_errors} . "\n";

        # Проверяем, есть ли какие-либо ошибки
        if (@$lref_missing_files
            ||

            @$lref_valuing_errors ||

            @$lref_funding_errors ||

            @$lref_future_errors ||

            @$lref_curves_errors
           )

        {

            # Печатаем заголовок секции в полный отчет
            print $out "#=========================================\n";

            print $out "#            ОТЧЕТ ${job}                \n";

            print $out "#=========================================\n";

            print $out
                "\n#-------------------------------------------------------\n";

            print $out
                "# ${id}                                                   \n";

            print $out
                "#-------------------------------------------------------\n";

            print $corp
                "\n#-------------------------------------------------------\n";

            # ИСПРАВЛЕНО: Получаем информацию о BOOK для секции PNL
            my $FilterName = substr( ${id}, 5, 10 );  # Извлекаем имя фильтра из ID
            
            # ИСПРАВЛЕНО: Исправлен синтаксис SQL запроса
            # Было: "SELECT Book FROM  Tot WHERE Active=1 AND RT='x' and fn='$fn;"
            # Стало: правильный запрос с переменной $FilterName
            my @taskresult = &sqlRequest(
                "SELECT Book FROM Tot WHERE Active=1 AND RT='x' AND fn='$FilterName'");

            print $corp
                "# ${id}                                                   \n";
            
            # ИСПРАВЛЕНО: Правильное отображение значения BOOK с проверкой
            if (@taskresult && defined $taskresult[0][0]) {
                print $corp "BOOK=$taskresult[0][0]\n";
                print $out "BOOK=$taskresult[0][0]\n";
            } else {
                # Если BOOK не найден, выводим сообщение об этом
                print $corp "BOOK=Не найден\n";
                print $out "BOOK=Не найден\n";
            }

            print $corp
                "#-------------------------------------------------------\n";

            # НОВОЕ: Вспомогательная функция для печати ограниченного количества ошибок
            # Выводит не более 5 ошибок в каждой секции и показывает общее количество
            sub print_limited_errors {
                my ($fh, $errors_ref, $section_name) = @_;
                my $num_errors = @$errors_ref;  # Получаем количество ошибок
                
                print $fh "#----------------------- $section_name ---------------------------\n";
                
                if ($num_errors > 5) {
                    # Печатаем первые 5 ошибок
                    for my $i (0..4) {
                        next unless defined $errors_ref->[$i];  # Пропускаем неопределенные значения
                        print $fh $errors_ref->[$i];
                    }
                    # Выводим сообщение о том, сколько еще ошибок не показано
                    print $fh "\n... и еще " . ($num_errors - 5) . " ошибок (всего: $num_errors)\n";
                } else {
                    # Если ошибок 5 или меньше, печатаем все
                    print $fh @$errors_ref;
                }
                
                print $fh "#-------------------------------------------------------\n";
            }

            # Секция P&L (прибыли и убытки)
            if (@$lref_valuing_errors)

            {

                my $num_errors = @$lref_valuing_errors;    # получаем количество ошибок

                # В полный отчет пишем все ошибки без ограничений
                print $out
                    "#----------------------- P&L ---------------------------\n";

                print $out @$lref_valuing_errors;

                print $out
                    "#-------------------------------------------------------\n";

                # НОВОЕ: В corp (тело письма) используем функцию с ограничением в 5 ошибок
                print_limited_errors($corp, $lref_valuing_errors, "P&L");

            }

            # Секция FUT (future ошибки)
            if (@$lref_future_errors)

            {

                my $num_errors = @$lref_future_errors;    # получаем количество ошибок

                print $corp
                    "#---------------------- FUT ------------------------\n";

                # НОВОЕ: Применяем ограничение в 5 ошибок к future_errors
                if ($num_errors > 5) {
                    # Печатаем первые 5 ошибок
                    for my $i (0..4) {
                        next unless defined $lref_future_errors->[$i];
                        print $corp $lref_future_errors->[$i];
                    }
                    print $corp "\n... и еще " . ($num_errors - 5) . " future ошибок (всего: $num_errors)\n";
                } else {
                    # Если ошибок 5 или меньше, печатаем все
                    print $corp @$lref_future_errors;
                }

                print $corp
                    "#-------------------------------------------------------\n";

            }

            # Секция FUNDING (ошибки финансирования)
            if (@$lref_funding_errors)

            {

                my $num_errors = @$lref_funding_errors;

                # В полный отчет пишем все ошибки
                print $out
                    "#---------------------- FUNDING ------------------------\n";

                print $out @$lref_funding_errors;

                print $out
                    "#-------------------------------------------------------\n";

                # НОВОЕ: В corp (тело письма) также ограничиваем funding_errors
                print $corp "#---------------------- FUNDING ------------------------\n";
                
                if ($num_errors > 5) {
                    # Печатаем первые 5 ошибок
                    for my $i (0..4) {
                        next unless defined $lref_funding_errors->[$i];
                        print $corp $lref_funding_errors->[$i];
                    }
                    print $corp "\n... и еще " . ($num_errors - 5) . " ошибок финансирования (всего: $num_errors)\n";
                } else {
                    # Если ошибок 5 или меньше, печатаем все
                    print $corp @$lref_funding_errors;
                }
                
                print $corp "#-------------------------------------------------------\n";

            }

            # Обработка лога ошибок (только если не легкий режим)
            print $out @$lref_error_log if ( !$g_light );

            my @error_log;

            if ( !$g_light ) {

                my $element = @$lref_error_log;

                # Очищаем ошибки от временных меток и лишних пробелов
                while ( $element >= 0 ) {

                    @$lref_error_log[$element] =~ s/(..):(..):(..)\.(...)//;  # удаляем время

                    @$lref_error_log[$element] =~ s/(..)\/(..)\/(..)\ //;      # удаляем дату

                    @$lref_error_log[$element] =~ s/^\ //g;                    # удаляем пробелы в начале

                    $element = $element - 1;

                }

            }

            # Секция CUR (ошибки кривых)
            if (@$lref_curves_errors)

            {

                my $num_errors = @$lref_curves_errors;

                # В полный отчет пишем все ошибки
                print $out
                    "#---------------------- CUR --------------------------\n";

                print $out @$lref_curves_errors;

                print $out
                    "#-------------------------------------------------------\n";

                print $corp
                    "#---------------------- CUR --------------------------\n";

                print $corp "\n";

                my $element = @$lref_curves_errors;

                # Очищаем ошибки кривых от временных меток
                while ( $element >= 0 ) {

                    @$lref_curves_errors[$element] =~ s/(..):(..):(..)\.(...)//;  # удаляем время

                    @$lref_curves_errors[$element] =~
                        s/(..)\/(..)\/(..)\/(..)//;                               # удаляем дату

                    @$lref_curves_errors[$element] =~ s/^\ //g;                    # удаляем пробелы в начале

                    $element = $element - 1;

                }

                my $element = @$lref_curves_errors;

                my $curseur = 0;

                my @test = ();

                # Удаляем дубликаты ошибок кривых
                while ( $curseur < $element ) {

                    if ( @$lref_curves_errors[$curseur] eq
                        @$lref_curves_errors[$curseur + 1] )

                    {
                        # Если текущая ошибка равна следующей, пропускаем (дубликат)
                        $curseur = $curseur + 1;

                    }
                    else {
                        # Иначе добавляем предыдущую ошибку в массив уникальных
                        $test[$curseur] = @$lref_curves_errors[$curseur - 1];

                        $curseur = $curseur + 1;

                    }

                }

                # НОВОЕ: Применяем ограничение в 5 ошибок к уникальным ошибкам кривых
                if (scalar(@test) > 5) {
                    # Печатаем первые 5 уникальных ошибок
                    for my $i (0..4) {
                        next unless defined $test[$i];
                        print $corp $test[$i];
                    }
                    print $corp "\n... и еще " . (scalar(@test) - 5) . " ошибок кривых (всего: " . scalar(@test) . ")\n";
                } else {
                    # Если уникальных ошибок 5 или меньше, печатаем все
                    print $corp @test;
                }

                print $corp
                    "#-------------------------------------------------------\n";

            }

            # Секция MISSING FILES (отсутствующие файлы)
            if (@$lref_missing_files)

            {

                my $num_errors = @$lref_missing_files;

                # В полный отчет пишем все отсутствующие файлы
                print $out
                    "\n#------------------ отсутствующие файлы ----------------------\n";

                print $out @$lref_missing_files;

                print $out
                    "#-------------------------------------------------------\n";

                # ЗАКОММЕНТИРОВАНО: Если нужно показывать отсутствующие файлы в теле письма,
                # раскомментируйте этот код и он будет применять ограничение в 5 ошибок
                #print $corp "\n#------------------ отсутствующие файлы ----------------------\n";
                #
                #if ($num_errors > 5) {
                #    for my $i (0..4) {
                #        next unless defined $lref_missing_files->[$i];
                #        print $corp $lref_missing_files->[$i];
                #    }
                #    print $corp "\n... и еще " . ($num_errors - 5) . " отсутствующих файлов (всего: $num_errors)\n";
                #} else {
                #    print $corp @$lref_missing_files;
                #}
                #
                #print $corp "#-------------------------------------------------------\n";

            }

        }

    }

}
```

**Основные изменения и их объяснение:**

1. **Исправление BOOK в секции PNL:**
   - Исправлен синтаксис SQL запроса (была ошибка с `$fn` и кавычками)
   - Добавлена проверка существования значения BOOK перед выводом
   - Добавлено сообщение "Не найден" если BOOK отсутствует

2. **Ограничение количества ошибок до 5:**
   - Создана вспомогательная функция `print_limited_errors` для переиспользования кода
   - В каждой секции проверяется количество ошибок
   - Если ошибок больше 5, выводятся только первые 5 и сообщение об остальных
   - Показывается общее количество ошибок в секции

3. **Сохранение полного отчета:**
   - В полный отчет (`$out`) по-прежнему записываются все ошибки без ограничений
   - Ограничения применяются только к телу письма (`$corp`)

4. **Комментарии на русском языке:**
   - Добавлены подробные комментарии, объясняющие каждый блок кода
   - Отмечены все исправленные и новые части кода
   - Объяснено назначение каждой секции отчета
   - 
