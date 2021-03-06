// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;
Перем Кластер_Владелец;

Перем ПараметрыОбъекта;

Перем Элементы;
Перем Лицензии;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера    - ссылка на родительский объект агента кластера
//   Кластер            - Кластер        - ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.РабочиеПроцессы);

	ПараметрыЛицензий = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.ЛицензииПроцессов);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);
	Лицензии = Новый Лицензии(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);

КонецПроцедуры

// Процедура получает список рабочих процессов от утилиты администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка рабочих процессов, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивПроцессов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивПроцессов.Добавить(Новый РабочийПроцесс(Кластер_Агент, Кластер_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивПроцессов);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "Имя") Экспорт

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список рабочих процессов
//   
// Параметры:
//   Отбор                    - Структура    - Структура отбора процессов (<поле>:<значение>)
//   ОбновитьПринудительно    - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список рабочих процессов 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	РабочиеПроцессы = Элементы.Список(Отбор, ОбновитьПринудительно, ЭлементыКакСоответствия);
	
	Возврат РабочиеПроцессы;

КонецФункции // Список()

// Функция возвращает список рабочих процессов кластера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка процессов, разделенные ","
//   ОбновитьПринудительно    - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список рабочих процессов кластера 1С
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	РабочиеПроцессы = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно, ЭлементыКакСоответствия); 
	
	Возврат РабочиеПроцессы;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество рабочих процессов в списке
//   
// Возвращаемое значение:
//    Число - количество рабочих процессов
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание рабочего процесса кластера 1С
//   
// Параметры:
//   Процесс                 - Строка    - Номер процесса в виде <адрес сервера>:<номер процесса ОС (pid))>
//   ОбновитьПринудительно   - Булево    - Истина - принудительно обновить данные (вызов RAC)
//   КакСоответствие         - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание рабочего процесса кластера 1С
//
Функция Получить(Знач Процесс, Знач ОбновитьПринудительно = Ложь, КакСоответствие = Ложь) Экспорт

	Процесс = СтрРазделить(Процесс, ":");

	Если Процесс.Количество() = 1 Тогда
		Процесс.Вставить(0, Кластер_Владелец.Получить("host"));
	КонецЕсли;

	Отбор = Новый Соответствие();
	Отбор.Вставить("host", Процесс[0]);
	Отбор.Вставить("pid", Процесс[1]);

	РабочиеПроцессы = Элементы.Список(Отбор, ОбновитьПринудительно, КакСоответствие);

	Если РабочиеПроцессы.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат РабочиеПроцессы[0];

КонецФункции // Получить()

// Функция возвращает список лицензий рабочих процессов 1С
//   
// Параметры:
//   ОбновитьПринудительно   - Булево    - Истина - обновить данные лицензий (вызов RAC)
//
// Возвращаемое значение:
//    ОбъектыКластера - список лицензий рабочих процессов 1С
//
Функция Лицензии(ОбновитьПринудительно = Ложь) Экспорт
	
	Возврат Лицензии;
	
КонецФункции // Лицензии()
